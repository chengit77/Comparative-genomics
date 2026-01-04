#!/usr/bin/env python3

import os
import re
import pandas as pd
import subprocess
import tempfile
import yaml

def load_configfile(configfile):
    
    def parse_genome_paths(d):
        d = d.copy()
        directory = d.pop('directory')
        d = {str(k): os.path.join(directory, v)
              for k,v in d.items()}
        return d
    
    with open(configfile) as f:
        config = yaml.safe_load(f)
    
    config['genomes'] = {
      'howlers': parse_genome_paths(config['howlers']),
      'outgroup': parse_genome_paths(config['outgroup'])}

    return config

def format_gene_list(config, genomes):
    
    genomes = list(genomes['howlers'] | genomes['outgroup'])

    df = pd.read_csv(config['gene_list'], sep='\t')

    cols = df.columns[(df.columns.str.contains('start')) &
                       (~df.columns.str.contains('gene'))]
    df[cols] = (df[cols] - config['window_size']).astype(str)

    cols = df.columns[(df.columns.str.contains('end')) &
                       (~df.columns.str.contains('gene'))]
    df[cols] = (df[cols] + config['window_size']).astype(str)

    for genome in genomes:
        df[genome] = (df[genome + '_contig'] + ':' +
                      df[genome + '_start'] + '-' + 
                      df[genome + '_end'])

    df = df.set_index('gene_name')

    return df[genomes]

def write_fasta(gene, genomes):

    def extract_sequence(genome):
        fasta = genomes[genome]
        query = gene[genome]
        cmd = ['samtools', 'faidx', fasta, query]
        result = subprocess.run(cmd, capture_output=True,
                                text=True)
        seq = (re.sub(r"^.*?\n", '', result.stdout)
               .replace('\n', ''))
        return seq + '\n'
    
    fasta = ''
    for genome in genomes.keys():
        fasta += '>' + genome + '\n'
        fasta += extract_sequence(genome)
    
    return fasta

def align_sequences(indir, fasta, label):
    
    seq_f = os.path.join(indir, label + '.fa')
    label = os.path.join(indir, label)

    with open(seq_f, 'w') as f:
        f.write(fasta)
    
    cmd = ['prank', '-d=' + seq_f, '-o=' + label, '-showtree']
    result = subprocess.run(cmd, capture_output=True, text=True)
    return
     
def merge_alignments(indir, outdir, gene):

    outfile = os.path.join(outdir, gene)

    cmd = ['prank', '-o=' + outfile,
           '-d1=' + os.path.join(indir, 'outgroup.best.fas'),
           '-t1=' + os.path.join(indir, 'outgroup.best.dnd'),
           '-d2=' + os.path.join(indir, 'howlers.best.fas'),
           '-t2=' + os.path.join(indir, 'howlers.best.dnd')]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return

def align_gene(gene, genomes, outdir):
    with tempfile.TemporaryDirectory() as tmp_dir:
        for g in ['howlers', 'outgroup']:
            fasta = write_fasta(gene, genomes[g])
            align_sequences(tmp_dir, fasta, g)
        merge_alignments(tmp_dir, outdir, gene.name)
    return

def visualize_gene(indir, outdir, gene):

    alignment = os.path.join(indir, gene + '.fas')
    outfile = os.path.join(outdir, gene + '.png')

    cmd = ['jalview', '--headless',
            '--open', alignment,
            '--image', outfile,
            '--props', 'jalview_settings.txt']
    result = subprocess.run(cmd, capture_output=True,
            text=True)
    return

def main(genes, genomes, alignment_dir, figure_dir):
    for g in genes.index:
        gene = genes.loc[g]
        align_gene(gene, genomes, alignment_dir)
        visualize_gene(alignment_dir, figure_dir, gene.name)


if __name__ == '__main__':

    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('--configfile', default='config.yaml',
                         type=str)
    parser.add_argument('--gene', default=None, type=str)
    args = parser.parse_args()

    config = load_configfile(args.configfile)

    os.makedirs(config['alignment_dir'], exist_ok=True)
    os.makedirs(config['figure_dir'], exist_ok=True)

    genes = format_gene_list(config, config['genomes'])

    if args.gene is not None:
        genes = genes.loc[[args.gene]]
    
    main(genes, config['genomes'], config['alignment_dir'],
         config['figure_dir'])
