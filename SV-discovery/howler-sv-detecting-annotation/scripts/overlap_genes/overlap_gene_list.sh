# /bin/bash

while [ "$1" != "" ]; do
    case $1 in
        --directory ) shift; SCRATCH=$1    ;;
	--reference ) shift; REFERENCE=$1  ;;
	--unique_to ) shift; UNIQUE_TO=$1  ;;
    esac
    shift
done

set -eu

VARIANTS=${SCRATCH}/variants/${UNIQUE_TO}_specific_SVs.bed
GENES=${SCRATCH}/genes/${REFERENCE}_genes_no_header.bed
OUTPUT=${SCRATCH}/variants/${UNIQUE_TO}_specific_SV_genes.bed

awk 'NR>1' ${VARIANTS} | \
	bedtools intersect -a - -b ${GENES} -wa -wb \
	> ${SCRATCH}/genes/overlap.bed

HEADER1=$(awk 'NR==1' ${VARIANTS})
HEADER2=$(awk 'NR==1' ${SCRATCH}/genes/${REFERENCE}_genes.bed)

echo $HEADER1 $HEADER2 > $OUTPUT
cat ${SCRATCH}/genes/overlap.bed >> ${OUTPUT}

exit 0
