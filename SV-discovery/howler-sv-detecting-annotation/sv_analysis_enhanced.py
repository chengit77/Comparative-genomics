#! /usr/bin/python3

import pandas as pd
from os import path, makedirs

# --- Utility mappings ---
REF_TO_NAME = {
    'GCF_000001405.40_GRCh38.p14': 'human',
    'GCF_011100555.1_mCalJa1.2.pat.X': 'marmoset',
    'GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri': 'chimp',
    'GCF_028885655.2_NHGRI_mPonAbe1-v2.0_pri': 'orangutan',
    'GCF_029281585.2_NHGRI_mGorGor1-v2.0_pri': 'gorilla',
    'GCF_037993035.1_T2T-MFA8v1.0': 'macaque'
}

HOWLER_LIST = [
    'A_belzebul_3273', 'A_belzebul_AU1', 'A_belzebul_NG1520',
    'A_caraya', 'A_guariba', 'A_seniculus'
]


def load_bedfile(directory, reference, howler):
    filename = path.join(directory,
        reference + '_genomic.fna-' + howler + '.svs.bed')
    bedfile = pd.read_csv(filename, sep='\t')
    print(f"[LOAD] {REF_TO_NAME[reference]} × {howler}: {len(bedfile)} SVs")
    return bedfile


def merge_dfs(df1, df2, method):
    if df1.empty:
        merged = df2
    else:
        merged = df1.merge(df2, how=method)

    print(f"[MERGE - {method}] df1({len(df1)}) × df2({len(df2)}) → merged({len(merged)})")
    return merged


def merge_within_ref(directory, reference, howlers):
    print(f"\n===== Merging within reference: {REF_TO_NAME[reference]} ({reference}) =====")
    df = pd.DataFrame()

    for howler in howlers:
        df2 = load_bedfile(directory, reference, howler)
        df = merge_dfs(df, df2, 'inner')

    print(f"[WITHIN-REF RESULT] {REF_TO_NAME[reference]} → {len(df)} shared SVs\n")
    return df


def merge_across_refs(directory, references, howlers):
    print("\n===== Merging across references =====")
    df = pd.DataFrame()

    for ref in references:
        df2 = merge_within_ref(directory, ref, howlers)
        print(f"[ACROSS-REF] Before merge: {len(df)} | merging with {REF_TO_NAME[ref]}: {len(df2)}")
        df = merge_dfs(df, df2, 'outer')
        print(f"[ACROSS-REF] After merge: {len(df)}")

    cols = [c for c in df.columns if ('start' in c) or ('end' in c)]
    df[cols] = df[cols].fillna(0).astype(int)

    print(f"[ACROSS-REF FINAL] Total SVs after merging all references: {len(df)}\n")
    return df


def list_shared_SVs(df, species_list):
    print("===== Filtering shared SVs =====")

    cols = [c for c in df.columns if 'contig' in c]
    absent = [a + '_contig' for a in species_list]
    keep_cols = [c for c in cols if c not in absent]

    idx = ((df[absent].isna().all(axis=1)) &
           (~df[keep_cols].isna().any(axis=1)))

    filtered = df[idx].reset_index(drop=True)
    print(f"[FILTER] Before: {len(df)}, after filtering: {len(filtered)}")

    to_drop = filtered.columns[
        filtered.isna().sum(axis=0) + (filtered == 0).sum(axis=0) == len(filtered)
    ]
    filtered = filtered.drop(to_drop, axis=1)

    print(f"[FILTER] Final SV count: {len(filtered)}\n")
    return filtered


def main(directory, unique_to):

    howlers = HOWLER_LIST

    references = list(REF_TO_NAME.keys())

    if unique_to == 'howler':
        species_list = []
    elif unique_to == 'monkey':
        species_list = ['marmoset', 'macaque']
    elif unique_to == 'new_world_monkey':
        species_list = ['marmoset']

    SVs = merge_across_refs(directory, references, howlers)
    variants = list_shared_SVs(SVs, species_list)

    print(f"===== FINAL RESULT: {unique_to}-specific SVs = {len(variants)} =====")
    return variants


if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('--directory', type=str)
    parser.add_argument('--unique_to', type=str)
    args = parser.parse_args()

    input_dir = path.join(args.directory, 'filtered_lists')
    output_dir = path.join(args.directory, 'variants')
    makedirs(output_dir, exist_ok=True)

    variants = main(input_dir, args.unique_to)

    filename = path.join(output_dir, args.unique_to + '_specific_SVs.bed')
    variants.to_csv(filename, sep='\t', index=False)




