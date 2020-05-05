#!/bin/bash -l
#SBATCH --cpus-per-task=60
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=01:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/ntEdit-%A.out
set -e
MEMORY=$((SLURM_MEM_PER_CPU/1024))G
ASSEM=Dstr_v1.5_ntEdit_RAILS/Dstr_v1.5_j1_R1_n2_edited.fa
#ln -s lordecreads.fa_vs_Dstr_v1.5.fa_250_0.9_rails.scaffolds.fa $ASSEM
kmer=50

#Get env right
export PATH=/rhome/arajewski/bigdata/Datura/software/bin:$PATH
export PATH=/rhome/arajewski/bigdata/Datura/software/ntEdit:$PATH

#Make bloom filter for desired kmer size
if [ ! -e Dstr_k$kmer.bf ]; then
    echo $(date): Generating bloom filter with nthits.
    nthits \
	-t $SLURM_CPUS_PER_TASK \
	-k $kmer \
	-p Dstr_ \
	--outbloom \
	--solid \
	/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq
    echo $(date): Done.
    #This took 1:11:00 with 16 cpus and 7G per cpu on highmem
else
    echo $(date): Bloom filter already present
fi

ntedit \
    -t $SLURM_CPUS_PER_TASK \
    -f $ASSEM \
    -k $kmer \
    -r Dstr_k$kmer.bf \
    -b Dstr_v1.5_ntEdit_RAILS/Dstr_v1.5_j1_R1_n3 \
    -v 0 \
    -m 1

scontrol show job $SLURM_JOB_ID
