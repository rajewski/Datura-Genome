#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=300G
##SBATCH -p highmem
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/LINKS-%A.out
set -e

# Set Inputs
ASSEM=Dstr_v1.7_Iterative/Dstr_v1.7_l1n2r1n3_l1n3r1n3_l1n3r1n3r1n2_l1n2r1n2_l1n2r1n2_l1n2r1n2_l1n2r1n1_l1n2r1n1_l1n2r1n1_l1n2r1n1_l1n2_l1n2_edited.fa
ASSEMBASE=$(echo $ASSEM | sed 's/\_edited\.fa//g')

# Find the iteration of LINKS to use by counting hte number of l's in the filename s a proxy for the number of links rounds
i=$(echo $ASSEM |tr -d -c 'l' | wc -m)

# specify the parameters for the lordec reads
dist=(750 1000 5000 10000 15000 20000 30000 40000 60000 70000 80000 90000 100000)
window=(4 3 3 3 3 2 2 2 2 2 2 2 2)
kmer=19

module load LINKS/1.8.4
LINKS \
    -f $ASSEM \
    -k $kmer \
    -b ${ASSEMBASE}_l1 \
    -t ${window[i]} \
    -d ${dist[i]} \
    -s lordecreads.txt \
    -l 4 \
    -r Dstr_v1.4_LINKS/Dstr_v1.4_links1_k19.bloom
