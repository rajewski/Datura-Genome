
REFPATH=~/bigdata/Datura//DNA-seq
REFASSEM=S_lycopersicum_chromosomes.4.00.fa.gz

#download the current best tomato reference genome
if [ ! -e $REFPATH/$REFASSEM ]; then
    echo Downloading SL4.0 reference genome...
    curl ftp://ftp.solgenomics.net/tomato_genome/assembly/build_4.00/S_lycopersicum_chromosomes.4.00.fa.gz \
	--output S_lycopersicum_chromosomes.4.00.fa.gz
    echo Done.
else
    echo SL4.0 reference genome already present.
fi

 
