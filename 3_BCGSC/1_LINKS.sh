#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=900G
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/LINKS-%A.out
set -e

#add LINKS to my path
module load LINKS/1.8.4

#specify distance parameters for megareads
#dist=(250 500 750 1000 5000 10000 15000 20000 30000 40000 60000 70000 80000 90000 100000)
#window=(6 5 5 5 4 3 3 2 2 2 2 2 2 2 2)

#specify the paramets for the lordec reads
dist=(750 1000 5000 10000 15000 20000 30000 40000 60000 70000 80000 90000 100000)
window=(4 3 3 3 3 2 2 2 2 2 2 2 2)
kmer=19

#First Round
if [ ! -e Dstr_v1.4_links1_k$kmer.scaffolds.fa ]; then
    i=0
    LINKS \
	-f Dstr_v1.3_k101-scaffolds.fa \
	-s lordecreads.txt \
	-b Dstr_v1.4_links1_k$kmer \
	-v 1 \
	-t ${window[i]} \
	-d ${dist[i]} \
	-l 4 \
	-z 500 \
	-k $kmer \
	-r Dstr_v1.4_links1_k19.bloom
else
    echo $(date): Round 1 of links already complete
fi

i=1
#Second through nth round
while [ $i -lt ${#dist[@]} ]
do
    if [ ! -e Dstr_v1.4_links$((i+1))_k$kmer.scaffolds.fa ]; then
	echo $(date): Running LINKS to create Dstr_v1.4_links$((i+1))_k$kmer.scaffolds.fa
	LINKS \
	    -f Dstr_v1.4_links${i}_k$kmer.scaffolds.fa \
	    -s lordecreads.txt \
	    -b Dstr_v1.4_links$((i+1))_k$kmer \
	    -v 1 \
	    -t ${window[i]} \
	    -d ${dist[i]} \
	    -l 4 \
	    -z 500 \
	    -k $kmer \
	    -r Dstr_v1.4_links1_k19.bloom
	echo $(date): Done.
	i=$[$i+1]
    else
	echo $(date): Dstr_v1.4_links$((i+1))_k$kmer.scaffolds.fa found, skipping to next iteration.
	i=$[$i+1]
    fi
done

scontrol show job $SLURM_JOB_ID
