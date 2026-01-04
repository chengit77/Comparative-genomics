#!/bin/bash
#SBATCH --mem=100GB
#SBATCH --job-name='pre'
#SBATCH --mail-user=bide.chen@duke.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output=test.%A_%a.out
#SBATCH --error=test.%A_%a.err
#SBATCH -p scavenger
# --array=1-88


DIR=/work/bc276/selection_analysis_codeml/LRT/codeml_M2_branch_site_output

python codeml_M2.py --directory $DIR --genes genelist.txt --outfile output_M2.txt




