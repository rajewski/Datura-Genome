#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=150G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/5_ScaffMatch-%A.out
set -e

#This script is currently not working. Something about python environments and dependencies is messing it up and honestly it isnt worth it

module load bowtie2/2.3.4.1
export PATH=/rhome/arajewski/bigdata/Datura/software/ScaffMatch:$PATH

#define insert size for file names
insert=(2000 4000 6000 8000 10000 12000 14000 16000 18000 20000 30000 40000 50000 60000 70000 80000 100000 )
#Get insert sizes from summary.txt from R script
obsinsert=( 1935 3959 5982 8000 10021 12039 14057 16076 18088 20104 30170 40191 50142 60015 69808 79199 94897 )
sdinsert=( 894 817 934 930 1104 1191 1255 1370 1484 1579 2291 2903 4012 5487 7100 10065 21873 )


#this is probably better with a while loop.....
a=0

echo $a
echo ${sdinsert[@]}

for i in $(seq 0 $((${#insert[@]}-1)))
do
    echo $(date): $i
    if [ $i -lt 1 ]; then
	echo $(date): Running iteration $((i+1)) of Scaffmatch.
	mkdir -p Dstr_v1.5-i${insert[i]}
	scaffmatch \
	    -m \
	    -w Dstr_v1.5-i${insert[i]} \
	    -c /rhome/arajewski/bigdata/Datura/2_MaSuRCA338/flye/assembly.fasta \
	    -s ${sdinsert[i]} \
	    -i ${obsinsert[i]} \
	    -p fr \
	    -1 ont.I${insert[i]}.FastSG_K22.sam.fwd.sam \
	    -2 ont.I${insert[i]}.FastSG_K22.sam.rev.sam 
    fi
    if [ $i -gt 0 ]; then
	#second through nth iteration
	mkdir -p Dstr_v1.5-i${insert[i]}
	scaffmatch \
	    -m \
	    -w Dstr_v1.5-i${insert[i]} \
	    -c Dstr_v1.5-i${insert[i-1]}/scaffolds.da \
	    -s ${sdinsert[i]} \
	    -i ${obsinsert[i]} \
	    -p fr \
	    -1 ont.I${insert[i]}.FastSG_K22.sam.fwd.sam \
	    -2 ont.I${insert[i]}.FastSG_K22.sam.rev.sam
   fi
done

scontrol show job $SLURM_JOB_ID
