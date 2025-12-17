#!/bin/bash


############################################
# A pipeline for:
# 1. MAFFT DNA & Protein alignment
# 2. pal2nal codon alignment
# 3. Convert FASTA to one-line
# 4. Convert to PHYLIP for PAML codeml
#
# Author: Bide Chen
# GitHub-ready version
############################################

### ===== USER CONFIGURATION =====

# DNA fasta directory (each gene as .fna or .fna_align)
DNA_DIR="/path/to/dna_sequences/"

# Protein fasta directory (each gene as .faa)
PROT_DIR="/path/to/protein_sequences/"

# Output directories
OUT_MAFFT_DNA="./mafft_dna/"
OUT_MAFFT_PROT="./mafft_pro/"
OUT_CODON="./codon/"
OUT_PHYLIP="./phylip/"

# Gene list file (optional). If empty, will auto-detect from DNA directory.
GENE_LIST="gene_list.txt"

# Tools
PAL2NAL="pal2nal.pl"
ONELINE="one_line_fasta.pl"
FASTATOPHY="FASTAtoPHYL.pl"

### ===== END USER CONFIGURATION =====


### ===== CREATE OUTPUT DIRECTORIES =====
mkdir -p $OUT_MAFFT_DNA $OUT_MAFFT_PROT $OUT_CODON $OUT_PHYLIP


### ===== GET GENE LIST =====
if [[ -f "$GENE_LIST" ]]; then
    GENES=$(cat "$GENE_LIST")
else
    GENES=$(ls $DNA_DIR | sed 's/\.fna//; s/\.fna_align//')
fi


### ===== 1. MAFFT alignment: DNA =====
echo "Running MAFFT for DNA..."
for gene in $GENES; do
    dna_file="${DNA_DIR}${gene}.fna"
    [[ ! -f $dna_file ]] && dna_file="${DNA_DIR}${gene}.fna_align"

    if [[ -f $dna_file ]]; then
        mafft "$dna_file" > "${OUT_MAFFT_DNA}${gene}_dna_mafft.fasta"
    else
        echo "Missing DNA file for gene $gene"
    fi
done


### ===== 2. MAFFT alignment: Protein =====
echo "Running MAFFT for protein..."
for gene in $GENES; do
    prot_file="${PROT_DIR}${gene}.faa"

    if [[ -f $prot_file ]]; then
        mafft "$prot_file" > "${OUT_MAFFT_PROT}${gene}_prot_mafft.fasta"
    else
        echo "Missing protein file for gene $gene"
    fi
done


### ===== 3. pal2nal: codon alignment =====
echo "Running pal2nal..."
for gene in $GENES; do
    dna="${OUT_MAFFT_DNA}${gene}_dna_mafft.fasta"
    prot="${OUT_MAFFT_PROT}${gene}_prot_mafft.fasta"

    if [[ -f $dna && -f $prot ]]; then
        perl $PAL2NAL $prot $dna -output fasta > "${OUT_CODON}${gene}_codon.fasta"
    else
        echo "Missing MAFFT alignment for $gene"
    fi
done


### ===== 4. Convert FASTA to one-line =====
echo "Converting codon alignments to one-line FASTA..."
for f in ${OUT_CODON}/*_codon.fasta; do
    perl $ONELINE "$f"
done


### ===== 5. Convert to PHYLIP =====
echo "Converting to PHYLIP format..."

for one in ${OUT_CODON}/*_codon_one_line.fa; do
    gene=$(basename $one _codon_one_line.fa)

    num=$(grep '>' $one | wc -l)
    len=$(sed -n '2p' $one | tr -d '\r\n' | wc --m)

    perl $FASTATOPHY "$one" $num $len > "${OUT_PHYLIP}${gene}.phy"
done

echo "Completed!"



