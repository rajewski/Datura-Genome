#module load  MaSuRCA/3.3.1

#try this python environemnt which maybe has more up-to-date versions of masurca and flye?
source activate masurca
masurca -o 2c_HybAssemble.sh 2a_HybAssembleConfig.txt

#First submission used until the genome size estimation which crashes with this much memory
#sbatch --ntasks 32 -p intel --mem 256gb --out ../history/2c_HybAssemble-%A.out --mail-user=araje002@ucr.edu --mail-type=ALL 2c_HybAssemble.sh

#second submission with higher memory
sbatch --ntasks 32 -p highmem --mem 512gb --out ../history/2c_HybAssemble-%A.out --mail-user=araje002@ucr.edu --mail-type=ALL 2c_HybAssemble.sh
