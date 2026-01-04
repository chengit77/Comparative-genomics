from Bio.Phylo.PAML import codeml
import pandas as pd
import numpy as np

def label_branches(omega):
    branches = ['0_proportion', '0_background', '0_foreground',
            '1_proportion', '1_background', '1_foreground',
            '2a_proportion', '2a_background', '2a_foreground',
            '2b_proportion', '2b_background', '2b_foreground']

    if not isinstance(omega, list):
        return {'w': omega}

    return dict(map(lambda k,v: (k,v), branches, omega))

def get_all_values(nested_dict):
    values = []
    for value in nested_dict.values():
        if isinstance(value, dict):
            values.extend(get_all_values(value))
        else:
            values.append(value)
    return values

def parse_file(filename, names):
    results = codeml.read(filename).get('NSsites').get(2)

    np = results.get('parameters').get('parameter list')
    np = len(np.split())

    lnL = results.get('lnL')

    omega = results.get('parameters').get('site classes')
    omega = get_all_values(omega)
    omega = label_branches(omega)

    return {names[0]: np, names[1]: lnL} | omega

def parse_codeml(directory, gene):
    file1 = (directory + '/' + gene +
             '_codon_one_line.fa.phy_M2null_branchsite.txt')
    results1 = parse_file(file1, ['np1', 'ln1'])

    file2 = (directory + '/' + gene +
             '_codon_one_line.fa.phy_M2_branchsite_six.txt')
    results2 = parse_file(file2, ['np2', 'ln2'])

    return results1 | results2

def main():

    with open(args['genes']) as gene_list:
        genes = gene_list.read().splitlines()

    output = {}

    for gene in genes:
        output[gene] = parse_codeml(args['directory'], gene)

    results = pd.DataFrame.from_dict(output,orient='index')
    results = results.reset_index()
    results = results.rename(columns={'index': 'gene'})

    results.to_csv(args['outfile'], index=False)

if __name__ == '__main__':

    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('--directory')
    parser.add_argument('--genes')
    parser.add_argument('--outfile')

    args = vars(parser.parse_args())

    main()
