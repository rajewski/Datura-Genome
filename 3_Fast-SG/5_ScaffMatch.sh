#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=150G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/5_ScaffMatch-%A.out
set -ev

module load bowtie2/2.3.4.1
#module unload miniconda3 python anaconda2 anaconda3
#module load python/2.7.14
#module load miniconda2
conda activate DaturaPy2

export PATH=/rhome/arajewski/bigdata/Datura/software/ScaffMatch:$PATH

#define insert size for file names
insert=(500 1000 2000 4000 6000 8000 10000 12000 14000 16000 18000 20000 30000 40000 50000 60000 70000 80000 100000 120000 150000 180000)
obsinsert=(414 921 1934 3961 5990 8019 10042 12067 14000 16000 18000 20000 30000 40000 50000 60000 70000 80000 100000 120000 150000 180000)
#set sd to 10% of insert size
a=0

#hardcore SD of insert size bc the loop is messing up
sdinsert=(41 92 193 396 599 801 1004 1206 1400 1600 1800 2000 3000 4000 5000 6000 7000 8000 10000 12000 15000 18000)

#for i in ${obsinsert[@]}
#do 
#    sdinsert[${a}]=$((i*10/100))
#    ((a++))
#done

echo $a
echo ${sdinsert[@]}

for i in $(seq 0 $((${#insert[@]}-1)))
do
    echo $(date): $i
    if [ $i -lt 1 ]; then
	echo $(date): Running iteration $((i+1)) of Scaffmatch.
	mkdir -p Dstr_v1.3_k101-i${insert[i]}
	scaffmatch \
	    -m \
	    -w Dstr_v1.3_k101-i${insert[i]} \
	    -c /rhome/arajewski/bigdata/Datura/2_ABySS/k_101/Dstr_v1.3_k101-scaffolds.fa \
	    -s ${sdinsert[i]} \
	    -i ${obsinsert[i]} \
	    -p fr \
	    -1 ultra_ont_raw.I${insert[i]}.FastSG_K22.sam.fwd.sam \
	    -2 ultra_ont_raw.I${insert[i]}.FastSG_K22.sam.rev.sam 
    fi
    if [ $i -gt 0 ]; then
	#second through nth iteration
	mkdir -p Dstr_v1.3_k101-i${insert[i]}
	scaffmatch \
	    -m \
	    -w Dstr_v1.3_k101-i${insert[i]} \
	    -c Dstr_v1.3_k101-i${insert[i-1]}/scaffolds.da \
	    -s ${sdinsert[i]} \
	    -i ${obsinsert[i]} \
	    -p fr \
	    -1 ultra_ont_raw.I${insert[i]}.FastSG_K22.sam.fwd.sam \
	    -2 ultra_ont_raw.I${insert[i]}.FastSG_K22.sam.rev.sam
   fi
done

scontrol show job $SLURM_JOB_ID
