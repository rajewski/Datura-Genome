module load  MaSuRCA/3.3.1
masurca -o 2c_HybAssemble.sh 2a_HybAssembleConfig.txt

sbatch --ntasks 32 -p intel --mem 256gb --out ./history/2c_HybAssemble-%A.out 2c_HybAssemble.sh
