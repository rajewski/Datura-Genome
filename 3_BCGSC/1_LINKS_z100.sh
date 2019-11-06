#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=270G
#SBATCH --time=4-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/LINKS_k%a-%A.out
set -e

#add LINKS to my path
#PATH=/rhome/arajewski/bigdata/Datura/software/links_v1.8.7:$PATH
#module load swig
module load LINKS/1.8.4
#specify distance parameters
dist=(10000 15000 20000 30000 40000 60000 70000 80000 90000 100000)
window=(10 10 10 10 10 10 10 10 10 10)
#kmer size is specified by the array job number

#First Round
if [ ! -e Dstr_v1.3_z100_links1_k$SLURM_ARRAY_TASK_ID.scaffolds.fa ]; then
    LINKS \
	-f Dstr_v1.3_k101-scaffolds.fa \
	-s nanopore.txt \
	-b Dstr_v1.3_z100_links1_k$SLURM_ARRAY_TASK_ID \
	-v 1 \
	-t 20 \
	-d 5000 \
	-z 100 \
	-k $SLURM_ARRAY_TASK_ID
else
    echo $(date): Round 1 of links already complete
fi

#Second through nth round
i=0
while [ $i -lt ${#dist[@]} ]
do
    if [ ! -e Dstr_v1.3_z100_links$((i+2))_k$SLURM_ARRAY_TASK_ID.scaffolds.fa ]; then
        echo $(date): Running LINKS to create Dstr_v1.3_z100_links$((i+2))_k$SLURM_ARRAY_TASK_ID.scaffolds.fa
        LINKS \
            -f Dstr_v1.3_z100_links$((i+1))_k$SLURM_ARRAY_TASK_ID.scaffolds.fa \
            -s nanopore.txt \
            -b Dstr_v1.3_z100_links$((i+2))_k$SLURM_ARRAY_TASK_ID \
            -v 1 \
            -t ${window[i]} \
            -d ${dist[i]} \
            -k $SLURM_ARRAY_TASK_ID
        echo $(date): Done.
        i=$[$i+1]
    else
        echo $(date): Dstr_v1.3_z100_links$((i+2))_k$SLURM_ARRAY_TASK_ID.scaffolds.fa found, skipping to next iteration.
        i=$[$i+1]
    fi
done



scontrol show job $SLURM_JOB_ID