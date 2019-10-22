#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=100G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/smudgeplot-%A.out
set -euv

if [ ! -e 'kmer_counts.kmc_suf' ]; then
    echo $(date): Running KMC first.
    #Lets run KMC first because it produces a sorted kmer histogram that should be 
    #easier and more memory effective for smudgeplot to use
    module load KMC/3.1.1
    mkdir -p tmp
    ls ../1_QCQA/*.fq.gz > FILES
    #counting kmer coverages between 1 and 10000x
    kmc -k31 -t$SLURM_NTASKS -m$((SLURM_MEM_PER_NODE/1024)) -ci1 -cs10000 @FILES kmer_counts tmp
    kmc_tools transform kmer_counts histogram kmer_k31.hist -cx10000
    echo $(date): Done with KMC.
else
    echo $(date): KMC has already been run, proceeding to smudgplot
fi

#You must have smudgeplot installed. I am using v 0.2.1
export PATH="/rhome/arajewski/software:$PATH"

module load miniconda3
if [ ! -e 'kmer_k31.dump' ]; then
    echo $(date): Creating kmer dump file.
    L=$(smudgeplot.py cutoff kmer_k31.hist L)
    U=$(smudgeplot.py cutoff kmer_k31.hist U)
    echo $L $U # these need to be sane values
    # L should be like 20 - 200
    # U should be like 500 - 3000
    module load KMC/3.1.1
    kmc_tools transform kmer_counts -ci$L -cx$U dump -s kmer_k31.dump
    echo $(date): Done.
else
    echo $(date): Kmer dump file already created.
fi

if [ ! -e 'kmer_pairs_coverages.tsv' ]; then
    echo $(date): Running Smudgeplot
    smudgeplot.py hetkmers --middle -o kmer_pairs kmer_k31.dump
    echo $(dte): Done.
else
    echo $(date): Smudgeplt hetkmers already completed.
fi

if [ ! -e 'smudgeplot_smudgeplot.png' ]; then
    echo $(date): Making smudgeplot itself.
    smudgeplot.py plot -k 31 kmer_pairs_coverages.tsv
    echo $(date): Done
else
    echo $(date): Smudgeplot already made.
fi

scontrol show job $SLURM_JOB_ID
