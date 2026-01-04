from Bio.Phylo.PAML import codeml
import pandas as pd

def label_branches(omega):
    branches = ['Howlers', 'Marmoset_Tamarin']

    if not isinstance(omega, list):
        return {'w': omega}

    omega.append(omega[0])
    omega = omega[1:]

    return dict(map(lambda k, v: (k, v), branches, omega))

def parse_file(filename, names):
    results = codeml.read(filename).get('NSsites').get(0)

    np = results.get('parameters').get('parameter list')
    np = len(np.split())

    lnL = results.get('lnL')

    omega = results.get('parameters').get('omega')
    omega = label_branches(omega)

    return {names[0]: np, names[1]: lnL} | omega

def parse_codeml(directory, gene):

    file1 = f"{directory}/{gene}_codon_one_line.fa.phy_M0.txt"
    results1 = parse_file(file1, ['np1', 'ln1'])

    file2 = f"{directory}/{gene}_codon_one_line.fa.phy_M0_branch.txt"
    results2 = parse_file(file2, ['np2', 'ln2'])

    # ==== 新增部分：直接读取完整 codeml 结构，从中提取 dN2, dS2 ====
    full_results2 = codeml.read(file2)
    branch_info = full_results2['NSsites'][0]['parameters']['branches']['9..10']

    dN2 = branch_info['dN']
    dS2 = branch_info['dS']

    # 加入到 results2 输出
    results2['dN2'] = dN2
    results2['dS2'] = dS2
    # ================================================

    return results1 | results2

def main():

    with open(args['genes']) as gene_list:
        genes = gene_list.read().splitlines()

    output = {}

    for gene in genes:
        output[gene] = parse_codeml(args['directory'], gene)

    results = pd.DataFrame.from_dict(output, orient='index')
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

