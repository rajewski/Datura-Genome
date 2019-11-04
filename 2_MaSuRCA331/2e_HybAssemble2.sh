#After the megareads step has completed (2d_megareads1.sh), I rerun the assembly script
#this is the submission to rerun the assembly script 
sbatch --ntasks 32 -p highmem --mem 512gb --out ../history/2e_HybAssemble2-%A.out --mail-user=araje002@ucr.edu --mail-type=ALL 2c_HybAssemble.sh
