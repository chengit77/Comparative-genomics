# /bin/bash

while [ "$1" != "" ]; do
    case $1 in
        --directory ) shift; SCRATCH=$1    ;;
	--reference ) shift; REFERENCE=$1  ;;
    esac
    shift
done

set -eu

SOURCE=${REFERENCE%%_*}
ACCESSION=${REFERENCE#*_}
ACC1=$(echo ${ACCESSION} | cut -c1-3)
ACC2=$(echo ${ACCESSION} | cut -c4-6)
ACC3=$(echo ${ACCESSION} | cut -c7-9)

ACCESSION=${SOURCE}/${ACC1}/${ACC2}/${ACC3}
NCBI=https://ftp.ncbi.nlm.nih.gov/genomes/all

INPUT=${REFERENCE}_feature_table.txt
OUTPUT=${SCRATCH}/genes/${REFERENCE}_genes

curl ${NCBI}/${ACCESSION}/${REFERENCE}/${INPUT}.gz \
       --create-dirs -o ${SCRATCH}/genes/${INPUT}.gz \
       --no-progress-meter

gunzip ${SCRATCH}/genes/${INPUT}.gz

awk -F'\t' -v OFS='\t' \
       ' $1=="gene" { print $7, $8, $9, $15 } ' \
       ${SCRATCH}/genes/${INPUT} > ${OUTPUT}_no_header.bed

sed $'1 i\\\ngene_contig\tgene_start\tgene_end\tgene_name' \
       	${OUTPUT}_no_header.bed > ${OUTPUT}.bed

exit 0
