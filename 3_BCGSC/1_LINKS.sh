#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=350G
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/LINKS_k%a-%A.out
set -e
#Initially the mem was set to 200GB, increased to 350GB and then down to 270Gb
#using either nanopore.txt for uncorrected reads or megareads.txt for the masurca corrected reads
#changing window size and lower limit (-l) to better scaffold small contigs

#add LINKS to my path
module load LINKS/1.8.4
#specify distance parameters
dist=(5000 10000 15000 20000 30000 40000 60000 70000 80000 90000 100000)
window=(2 2 2 2 2 2 2 2 2 2 2)

#First Round
if [ ! -e Dstr_v1.3_l4d2_links1_k15.scaffolds.fa ]; then
    LINKS \
	-f Dstr_v1.3_k101-scaffolds.fa \
	-s megareads.txt \
	-b Dstr_v1.3_l4d2_links1_k15 \
	-v 1 \
	-t 2 \
	-d 1000 \
	-l 4 \
	-z 100 \
	-k 15
else
    echo $(date): Round 1 of links already complete
fi

#Second through nth round
i=0
while [ $i -lt ${#dist[@]} ]
do
    if [ ! -e Dstr_v1.3_l4d2_links$((i+2))_k15.scaffolds.fa ]; then
	echo $(date): Running LINKS to create Dstr_v1.3_l4d2_links$((i+2))_k15.scaffolds.fa
	LINKS \
	    -f Dstr_v1.3_l4d2_links$((i+1))_k15.scaffolds.fa \
	    -s megareads.txt \
	    -b Dstr_v1.3_l4d2_links$((i+2))_k15 \
	    -v 1 \
	    -t ${window[i]} \
	    -d ${dist[i]} \
	    -l 4 \
	    -z 100 \
	    -k 15
	echo $(date): Done.
	i=$[$i+1]
    else
	echo $(date): Dstr_v1.3_l4d2_links$((i+2))_k15.scaffolds.fa found, skipping to next iteration.
	i=$[$i+1]
    fi
done

scontrol show job $SLURM_JOB_ID
