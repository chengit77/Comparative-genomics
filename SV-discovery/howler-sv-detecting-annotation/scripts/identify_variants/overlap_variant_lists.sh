#! /usr/bin/python3

import pandas as pd
from os import path, makedirs

def load_bedfile(directory, reference, howler):
    filename = path.join(directory,
            reference + '_genomic.fna-' + howler + '.svs.bed')
    bedfile = pd.read_csv(filename, sep='\t')
    return bedfile

def merge_dfs(df1, df2, method):
    if df1.empty:
        return df2
    else:
        return df1.merge(df2, how=method)

def merge_within_ref(directory, reference, howlers):
    df = pd.DataFrame()
    for howler in howlers:
        df2 = load_bedfile(directory, reference, howler)
        df = merge_dfs(df, df2, 'inner')
    return df


def merge_across_refs(directory, references, howlers):
    df = pd.DataFrame()
    for reference in references:
        df2 = merge_within_ref(directory, reference, howlers)
        df = merge_dfs(df, df2, 'outer')
    cols = [c for c in df.columns
            if ('start' in c) or ('end' in c)]
    df[cols] = df[cols].fillna(0).astype(int)
    return df

def list_shared_SVs(df, species_list):
    cols = [c for c in df.columns if 'contig' in c]
    absent = [a + '_contig' for a in species_list]
    cols = [c for c in cols if c not in absent]
    idx = ((df[absent].isna().all(axis=1)) & 
            (~df[cols].isna().any(axis=1)))
    df = df[idx].reset_index(drop=True)
    to_drop = df.columns[df.isna().sum(axis=0) +
            (df == 0).sum(axis=0) == len(df)]
    df = df.drop(to_drop,axis=1)
    return df

def main(directory, unique_to):
    howlers=['A_belzebul_3273', 'A_belzebul_AU1',
        'A_belzebul_NG1520', 'A_caraya', 'A_guariba',
        'A_seniculus']

    references=['GCF_000001405.40_GRCh38.p14',
    'GCF_011100555.1_mCalJa1.2.pat.X',
    'GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri',
    'GCF_028885655.2_NHGRI_mPonAbe1-v2.0_pri',
    'GCF_029281585.2_NHGRI_mGorGor1-v2.0_pri',
    'GCF_037993035.1_T2T-MFA8v1.0']

    if unique_to == 'howler':
            species_list = []
    elif unique_to == 'monkey':
            species_list = ['marmoset', 'macaque']
    elif unique_to == 'new_world_monkey':
            species_list = ['marmoset']

    SVs = merge_across_refs(directory, references, howlers)
    variants = list_shared_SVs(SVs, species_list)
    
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
    filename = path.join(output_dir,
      args.unique_to + '_specific_SVs.bed')
    variants.to_csv(filename, sep='\t', index=False)
