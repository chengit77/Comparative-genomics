#! /bin/bash

set -e

SMARTIE_SV=/work/bc276/dashiell-smartiesv/smartie-sv
export PATH="$SMARTIE_SV/bin:$PATH"

source activate smartie-sv

# Index reference genome
#sawriter $SMARTIE_SV/example/GCF_011100555.1_mCalJa1.2.pat.X_genomic.fna


REF=$(cd /work/bc276/dashiell-smartiesv/smartie-sv/example && ls *.fna)


PATH_CONFIG=/work/bc276/dashiell-smartiesv/smartie-sv/pipeline/

HOWLERS="A_belzebul_AU1"
SUFFIX="_HM.cleaned.fa"

for i in $REF;
do
        FILE="config.json"
        echo "{ " > $PATH_CONFIG$FILE
        echo "        \"install\": \"/work/bc276/dashiell-smartiesv/smartie-sv\"," >> $PATH_CONFIG$FILE
        echo "        \"targets\" : {" >> $PATH_CONFIG$FILE
        echo "                  \"$i\" : \"../example/"$i"\"" >> $PATH_CONFIG$FILE
        echo "                  }," >> $PATH_CONFIG$FILE
        echo "        \"queries\" : {" >> $PATH_CONFIG$FILE
        echo "                 \"$HOWLERS\"   : \""../example/"$HOWLERS$SUFFIX\"" >> $PATH_CONFIG$FILE
        echo "           }," >> $PATH_CONFIG$FILE
        echo "}" >> $PATH_CONFIG$FILE

# Run pipeline
cd $SMARTIE_SV/pipeline
snakemake -s Snakefile --profile slurm >> log 2>&1 &

sleep 65

done
