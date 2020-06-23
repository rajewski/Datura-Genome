#!/bin/sh
if [ ! -e '2f_HybAssemble.sh' ]; then
    echo $(date): Loading MaSuRCA to generate assembly script.
    module unload miniconda2
    module load miniconda3
    module load MaSuRCA/3.3.8
    masurca -o 2f_HybAssemble.sh 2a_HybAssembleConfig.txt
    echo $(date): Assembly script complete.
else
    echo $(date): Assembly script already present, proceeding to submission
fi

#First submission used until the genome size estimation which crashes with this much memory
# how much of the submission environment is inherited?
module unload miniconda2 
module load miniconda3
module load MaSuRCA/3.3.8

echo Submitting 2f_HybAssemble.sh
#second submission with higher memory
sbatch \
    --ntasks 1 \
    --cpus-per-task=60 \
    -p intel,batch \
    --mem-per-cpu=7Gb \
    --out ../history/2f_HybAssemble-%A.out \
    --mail-user=araje002@ucr.edu \
    --mail-type=ALL 2f_HybAssemble.sh 
