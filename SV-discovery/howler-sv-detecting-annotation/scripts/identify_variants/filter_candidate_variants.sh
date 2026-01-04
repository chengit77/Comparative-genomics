#! /bin/bash

while [ "$1" != "" ]; do
    case $1 in
        --directory ) shift; SCRATCH=$1    ;;
	--reference ) shift; REFERENCE=$1  ;;
        --howler    ) shift; HOWLER=$1     ;;
    esac
    shift
done

set -eu

INPUT=${SCRATCH}/original_lists
OUTPUT=${SCRATCH}/filtered_lists
mkdir -p ${OUTPUT}

SCRIPTS=$(dirname $0)
FILE=${REFERENCE}_genomic.fna-${HOWLER}.svs.bed

bedtools intersect \
	-a ${INPUT}/${FILE} -b ${INPUT}/${FILE} -wa -wb | \
	cut -f 1-5,7-9 > ${OUTPUT}/${FILE}

python3 ${SCRIPTS}/filter_candidate_variants.py \
        --directory ${OUTPUT} \
        --reference ${REFERENCE} \
        --howler ${HOWLER}

exit 0
