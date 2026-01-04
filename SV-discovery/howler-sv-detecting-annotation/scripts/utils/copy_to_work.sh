#! /bin/bash

WORK=/work/djm87/howler_SV/original_lists
mkdir -p ${WORK}

BC276=/datacommons/goldberg/bide_chen/new/dashiell-smartiesv/smartie-sv/pipeline/variants/

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

SUFFIX=genomic.fna

for REFERENCE in ${REFERENCES[@]}; do
    for HOWLER in ${HOWLERS[@]}; do
        FILE=${REFERENCE}_${SUFFIX}-${HOWLER}.svs.bed
        cp ${BC276}/${HOWLER}/${FILE} ${WORK}
    done
done

exit 0
