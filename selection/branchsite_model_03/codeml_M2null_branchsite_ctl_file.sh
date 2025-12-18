#!/bin/bash

ALIGN_PATH=/path/to/codon_phy/

TREE_PATH=/path/to/tree/
TREE_FILE="tree.treefile"

OUTPUT_PATH=/path/to/output_directory/


ALIGN=$(cd $ALIGN_PATH  && ls *.phy)

for i in $ALIGN
do
	NAME=$(echo $i)
	echo "working on $NAME"
	FILE=$NAME"_codeml-M2null_branchsite.ctl"
	echo "seqfile = $ALIGN_PATH$i            * Path to the alignment file" > $FILE
	echo "treefile = $TREE_PATH$TREE_FILE           * Path to the tree file" >> $FILE
	echo "outfile = $OUTPUT_PATH$i"_M2null_branchsite.txt"            * Path to the output file" >> $FILE
	echo "" >> $FILE
	echo "noisy = 3              * How much rubbish on the screen" >> $FILE
	echo "verbose = 1              * More or less detailed report" >> $FILE
	echo "" >> $FILE
	echo "seqtype = 1              * Data type" >> $FILE
	echo "ndata = 1           * Number of data sets or loci" >> $FILE
	echo "icode = 0              * Genetic code" >> $FILE
	echo "cleandata = 0              * Remove sites with ambiguity data?" >> $FILE
	echo "" >> $FILE
	echo "model = 2         * Models for ω varying across lineages" >> $FILE
	echo "NSsites = 2          * Models for ω varying across sites" >> $FILE
	echo "CodonFreq = 7        * Codon frequencies" >> $FILE
	echo "estFreq = 0        * Use observed freqs or estimate freqs by ML" >> $FILE
	echo "clock = 0          * Clock model" >> $FILE
	echo "fix_omega = 1         * Estimate or fix omega" >> $FILE
	echo "omega = 1        * Initial or fixed omega" >> $FILE
done
















