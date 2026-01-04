#! /bin/bash
#SBATCH --job-name=overlap_genes
#SBATCH --mem=2G
#SBATCH --partition=goldberg,common,scavenger
#SBATCH --output=logs/%x-%A.out

set -eu
#source activate howler_SV

PROJECT=/hpc/dctrl/bc276/howler_SV
WORK=/work/bc276/howler_SV
TASK=overlap_genes

REFERENCE=GCF_000001405.40_GRCh38.p14
SCRIPTS=${PROJECT}/scripts/${TASK}

sh ${SCRIPTS}/download_gene_list.sh \
	--directory ${WORK} --reference ${REFERENCE}

for UNIQUE_TO in howler monkey new_world_monkey; do
    sh ${SCRIPTS}/overlap_gene_list.sh \
       --directory ${WORK} --reference ${REFERENCE} \
       --unique_to ${UNIQUE_TO}
done

rm -r ${WORK}/genes

exit 0
