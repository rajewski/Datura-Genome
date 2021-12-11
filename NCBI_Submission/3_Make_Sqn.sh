#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=15
#SBATCH -p highmem
#SBATCH --mem-per-cpu=7G
#SBATCH --time 3-00:00:00
#SBATCH --mail-user=alex.rajewski@cshs.org
#SBATCH --mail-type=ALL
#SBATCH -o tbl2gbk-%A.out

module load funannotate/1.8

funannotate util tbl2gbk \
	-i Datura_stramonium_NCBI_Renamed.tbl \
	-f Datura_stramonium.scaffolds_NCBI_Rename_MTmask.fa \
	-s "Datura stramonium" \
	--sbt Dstr.sbt \
	-o Dstr_MTmask
 

