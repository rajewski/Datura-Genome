#try this python environemnt which maybe has more up-to-date versions of masurca and flye?
if [ ! -e '2c_HybAssemble.sh' ]; then
    echo $(date): Loading MaSuRCA to generate assembly script.
    module unload miniconda2
    module load miniconda3
    conda activate Datura
    masurca -o 2c_HybAssemble.sh 2a_HybAssembleConfig.txt
    echo $(date): Assembly script complete.
else
    echo $(date): Assembly script already present, proceeding to submission
fi

#First submission used until the genome size estimation which crashes with this much memory
# how much of the submission environment is inherited?
module unload miniconda2 
module load miniconda3
conda activate Datura

sbatch --ntasks 32 -p intel,batch --mem 256gb --out ../history/2c_HybAssemble-%A.out --mail-user=araje002@ucr.edu --mail-type=ALL 2c_HybAssemble.sh

#second submission with higher memory
#sbatch --ntasks 32 -p highmem --mem 512gb --out ../history/2c_HybAssemble-%A.out --mail-user=araje002@ucr.edu --mail-type=ALL 2c_HybAssemble.sh
