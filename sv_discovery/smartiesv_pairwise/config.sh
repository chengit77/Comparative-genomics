

REF=$(cd /work/bc276/dashiell-smartiesv/smartie-sv/example && ls *.fna)


PATH_CONFIG=/work/bc276/dashiell-smartiesv/smartie-sv/pipeline/



HOWLERS="A_belzebul_AU1"



SUFFIX="_HM.cleaned.fa"

for i in $REF;
do
        FILE="config.json"
        echo "{ " >> $PATH_CONFIG$FILE
        echo "        \"install\": \"/work/bc276/dashiell-smartiesv/smartie-sv\"," >> $PATH_CONFIG$FILE
        echo "        \"targets\" : {" >> $PATH_CONFIG$FILE
        echo "                  \"$i\" : \"../example/"$i"\"" >> $PATH_CONFIG$FILE
        echo "                  }," >> $PATH_CONFIG$FILE
        echo "        \"queries\" : {" >> $PATH_CONFIG$FILE
        echo "                 \"$HOWLERS\"   : \""../example/"$HOWLERS$SUFFIX\"" >> $PATH_CONFIG$FILE
        echo "           }," >> $PATH_CONFIG$FILE
        echo "}" >> $PATH_CONFIG$FILE
done


