#! /bin/bash

set -e

SMARTIE_SV=/work/bc276/dashiell-smartiesv/smartie-sv
export PATH="$SMARTIE_SV/bin:$PATH"

source activate smartie-sv

# Index reference genome
#sawriter $SMARTIE_SV/example/GCF_011100555.1_mCalJa1.2.pat.X_genomic.fna

# Run pipeline
cd $SMARTIE_SV/pipeline
snakemake -s Snakefile --profile slurm > log 2>&1 &
