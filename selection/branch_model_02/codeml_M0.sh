#!/bin/bash

PAML_CODEML=/path/to/codeml
CTL_PATH=/path/to/ctl/file

CODEML_M0=$(cd $CTL_PATH && ls *.ctl)


for i in $CODEML_M0
do
	NAME=$(echo $i)
	echo "working on $NAME"
	FILE=$NAME"_codeml_M0.sh"
	CODEML_PATH=$CTL_PATH
	CODEML=$PAML_CODEML
	echo "#!/bin/bash" > $FILE
	echo "#SBATCH --mem=50GB" >> $FILE
	echo "#SBATCH -p scavenger" >> $FILE
	echo "$CODEML $CODEML_PATH$i" >> $FILE
	yes \n | sbatch $FILE
done

















