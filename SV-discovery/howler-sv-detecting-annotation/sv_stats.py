#!/usr/bin/python3

import pandas as pd
from os import path, makedirs

# -------------------------
# Mapping provided
# -------------------------
REF_TO_NAME = {
    'GCF_000001405.40_GRCh38.p14': 'human',
    'GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri': 'chimpanzee',
    'GCF_029281585.2_NHGRI_mGorGor1-v2.0_pri': 'gorilla',
    'GCF_028885655.2_NHGRI_mPonAbe1-v2.0_pri': 'orangutan',
    'GCF_037993035.1_T2T-MFA8v1.0': 'macaque',
    'GCF_011100555.1_mCalJa1.2.pat.X': 'marmoset'
}

HOWLER_LIST = [
    'A_belzebul_3273', 'A_belzebul_AU1', 'A_belzebul_NG1520',
    'A_caraya', 'A_guariba', 'A_seniculus'
]

# -------------------------
# Loading BED files
# -------------------------
def load_bedfile(directory, reference, howler):
    filename = path.join(directory, reference + '_genomic.fna-' + howler + '.svs.bed')
    bedfile = pd.read_csv(filename, sep='\t')
    return bedfile


def merge_dfs(df1, df2, method):
    if df1.empty:
        return df2
    else:
        return df1.merge(df2, how=method)


def list_shared_SVs(df, species_list):
    cols = [c for c in df.columns if 'contig' in c]

    absent = [a + '_contig' for a in species_list]
    cols_present = [c for c in cols if c not in absent]

    idx = ((df[absent].isna().all(axis=1)) &
           (~df[cols_present].isna().any(axis=1)))

    filtered = df[idx].reset_index(drop=True)

    to_drop = filtered.columns[
        filtered.isna().sum(axis=0) + (filtered == 0).sum(axis=0) == len(filtered)
    ]
    filtered = filtered.drop(to_drop, axis=1)

    return filtered


# -------------------------
# New: merge_across_refs with stepwise filtering
# -------------------------
def merge_across_refs_stepwise(directory, references, howlers, species_list):
    df = pd.DataFrame()
    summary = []   # for storing count after each REF

    for ref in references:
        df2 = pd.DataFrame()

        # merge within reference
        for howler in howlers:
            bed = load_bedfile(directory, ref, howler)
            df2 = merge_dfs(df2, bed, "inner")

        # now merge across previous refs
        df = merge_dfs(df, df2, "outer")

        # fill missing numeric
        cols = [c for c in df.columns if ('start' in c) or ('end' in c)]
        df[cols] = df[cols].fillna(0).astype(int)

        # filter UNIQUE shared SVs *after this REF*
        filtered = list_shared_SVs(df.copy(), species_list)

        summary.append({
            "reference": REF_TO_NAME[ref],
            "num_shared_SVs": len(filtered)
        })

    return df, pd.DataFrame(summary)


def main(directory, unique_to):

    if unique_to == 'howler':
        species_list = []
    elif unique_to == 'monkey':
        species_list = ['marmoset', 'macaque']
    elif unique_to == 'new_world_monkey':
        species_list = ['marmoset']

    references = [
        'GCF_000001405.40_GRCh38.p14',                      # human
        'GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri',          # chimpanzee
        'GCF_029281585.2_NHGRI_mGorGor1-v2.0_pri',          # gorilla
        'GCF_028885655.2_NHGRI_mPonAbe1-v2.0_pri',          # orangutan
        'GCF_037993035.1_T2T-MFA8v1.0',                     # macaque
        'GCF_011100555.1_mCalJa1.2.pat.X'                   # marmoset
    ]

    merged_df, summary_df = merge_across_refs_stepwise(directory, references, HOWLER_LIST, species_list)

    final_variants = list_shared_SVs(merged_df, species_list)

    return final_variants, summary_df


# -------------------------
# CLI part
# -------------------------
if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('--directory', type=str)
    parser.add_argument('--unique_to', type=str)
    args = parser.parse_args()

    input_dir = path.join(args.directory, 'filtered_lists')
    output_dir = path.join(args.directory, 'variants')
    makedirs(output_dir, exist_ok=True)

    variants, summary = main(input_dir, args.unique_to)

    # save results
    variants.to_csv(
        path.join(output_dir, args.unique_to + '_specific_SVs.bed'),
        sep='\t', index=False
    )

    summary.to_csv(
        path.join(output_dir, args.unique_to + '_stepwise_summary.tsv'),
        sep='\t', index=False
    )


