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


DIR=/hpc/dctrl/bc276/selection_new/selection_analysis_codeml/LRT/codeml_M0_M0_branch_output/

python codeml_branch_dNdS.py --directory $DIR --genes genelist.txt --outfile output.txt




