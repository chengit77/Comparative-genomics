#!/bin/bash

PAML_CODEML=/path/to/codeml
CTL_PATH=/path/to/null/ctl/file

CODEML_M0=$(cd $CTL_PATH && ls *.ctl)


for i in $CODEML_M0
do
	NAME=$(echo $i)
	echo "working on $NAME"
	FILE=$NAME"_codeml_M2null_branchsite.sh"
	CODEML_PATH=$CTL_PATH
	CODEML=$PAML_CODEML
	echo "#!/bin/bash" > $FILE
	echo "#SBATCH --mem=10GB" >> $FILE
	echo "#SBATCH -p scavenger" >> $FILE
	echo "$CODEML $CODEML_PATH$i" >> $FILE
	yes \n | sbatch $FILE
done

















