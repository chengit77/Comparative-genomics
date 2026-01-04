#! /usr/bin/python3

from os import path
import pandas as pd

def name_genomes(reference, howler):
    ref_dict = {'GCF_000001405.40_GRCh38.p14': 'human',
            'GCF_011100555.1_mCalJa1.2.pat.X': 'marmoset',
            'GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri': 'chimp',
            'GCF_028885655.2_NHGRI_mPonAbe1-v2.0_pri': 'orangutan',
            'GCF_029281585.2_NHGRI_mGorGor1-v2.0_pri': 'gorilla',
            'GCF_037993035.1_T2T-MFA8v1.0': 'macaque'}
    howler_dict = {'A_belzebul_3273': '3273',
        'A_belzebul_AU1': 'AU1', 'A_belzebul_NG1520': 'NG1520',
        'A_caraya': 'caraya', 'A_guariba': 'guariba',
        'A_seniculus': 'seniculus'}
    target = ref_dict[reference]
    query = howler_dict[howler]
    return target, query

def load_bedfile(filename, target, query):
    cols = [target + '_contig', target + '_start', target + '_end',
            'sv_type', 'sv_len',
            query + '_contig', query + '_start', query + '_end']
    bedfile = pd.read_csv(filename, sep='\t', names=cols)
    return bedfile

def remove_duplicates(df, subset='all'):
    cols = df.columns.tolist()
    if subset != 'all':
        cols = [c for c in cols if c.startswith(subset)]
    df2 = df[cols].value_counts().reset_index()
    df = df.merge(df2, on=cols)
    df = (df[df['count'] == 1].reset_index(drop=True)
            .drop('count',axis=1))
    return df

def main(filename, reference, howler):
    target, query = name_genomes(reference, howler)
    svs = load_bedfile(filename, target, query)
    svs = remove_duplicates(svs)
    svs = remove_duplicates(svs, target)
    svs = remove_duplicates(svs, query)
    return svs

if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('--directory', type=str)
    parser.add_argument('--reference', type=str)
    parser.add_argument('--howler', type=str)
    args = parser.parse_args()

    filename = path.join(args.directory,
            args.reference + '_genomic.fna-' +
            args.howler + '.svs.bed')
    svs = main(filename, args.reference, args.howler)
    svs.to_csv(filename, sep='\t', index=False)
