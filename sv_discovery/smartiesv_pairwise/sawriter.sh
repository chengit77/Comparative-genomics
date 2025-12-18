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

#marmoset
#/work/bc276/dashiell-smartiesv/smartie-sv/bin/sawriter /work/bc276/dashiell-smartiesv/smartie-sv/example/GCF_011100555.1_mCalJa1.2.pat.X_genomic.fna 

#macaque
#/work/bc276/dashiell-smartiesv/smartie-sv/bin/sawriter /work/bc276/dashiell-smartiesv/smartie-sv/example/GCF_037993035.1_T2T-MFA8v1.0_genomic.fna

#orangutan
#/work/bc276/dashiell-smartiesv/smartie-sv/bin/sawriter /work/bc276/dashiell-smartiesv/smartie-sv/example/GCF_028885655.2_NHGRI_mPonAbe1-v2.0_pri_genomic.fna

#gorilla
#/work/bc276/dashiell-smartiesv/smartie-sv/bin/sawriter /work/bc276/dashiell-smartiesv/smartie-sv/example/GCF_029281585.2_NHGRI_mGorGor1-v2.0_pri_genomic.fna

#chimpanzee
#/work/bc276/dashiell-smartiesv/smartie-sv/bin/sawriter /work/bc276/dashiell-smartiesv/smartie-sv/example/GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri_genomic.fna

#human
/work/bc276/dashiell-smartiesv/smartie-sv/bin/sawriter /work/bc276/dashiell-smartiesv/smartie-sv/example/GCF_000001405.40_GRCh38.p14_genomic.fna


