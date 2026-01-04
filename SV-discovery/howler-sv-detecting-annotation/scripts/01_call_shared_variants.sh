#! /bin/bash
#SBATCH --job-name=shared_variants
#SBATCH --mem=2G
#SBATCH --partition=goldberg,common,scavenger
#SBATCH --output=test.%A_%a.out
#SBATCH --error=test.%A_%a.err

set -eu
#source activate howler_SV

PROJECT=/hpc/dctrl/bc276/howler_SV
SCRATCH=/hpc/dctrl/bc276/howler_SV

HOWLERS=(A_belzebul_3273 A_belzebul_AU1 A_belzebul_NG1520
        A_caraya A_guariba A_seniculus)

REFERENCES=(
        GCF_000001405.40_GRCh38.p14
        GCF_011100555.1_mCalJa1.2.pat.X
        GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri
        GCF_028885655.2_NHGRI_mPonAbe1-v2.0_pri
        GCF_029281585.2_NHGRI_mGorGor1-v2.0_pri
        GCF_037993035.1_T2T-MFA8v1.0
)

PARTITIONS='goldberg,common,scavenger'

SCRIPTS=${PROJECT}/scripts/identify_variants

# Filter individual smartie-sv output files
CMD=${SCRATCH}/commands.txt
> ${CMD}
for REFERENCE in ${REFERENCES[@]}; do
    for HOWLER in ${HOWLERS[@]}; do
        echo "${SCRIPTS}/filter_candidate_variants.sh \
          --directory ${SCRATCH} --reference ${REFERENCE} \
	  --howler ${HOWLER}" >> ${CMD}
    done
done

sbatch --wait --job-name='filter-SVs' --mem=2GB \
        --array=1-36 --partition=${PARTITIONS} \
        --output=${SCRATCH}'/logs/%x-%A_%a.out' \
        --wrap="sed -n \${SLURM_ARRAY_TASK_ID}p ${CMD} | sh -"


# Find shared structural variants across lists
for UNIQUE_TO in howler monkey new_world_monkey; do
    sh ${SCRIPTS}/overlap_variant_lists.sh \
       --directory ${SCRATCH} --unique_to ${UNIQUE_TO}
done
#
## Clean up
#rm -r ${SCRATCH}/filtered_lists ${SCRATCH}/commands.txt

exit 0
