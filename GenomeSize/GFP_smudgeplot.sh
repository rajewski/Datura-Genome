#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=100G
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/smudgeplot-%A.out
set -eu

kmer=19
GFP=( GFP_1 GFP_2 GFP_3 )

for Seq in ${GFP[@]}; do
    if [ ! -e ${Seq}_k${kmer}_counts.kmc_suf ]; then
	echo $(date): Running KMC first.
	#Lets run KMC first because it produces a sorted kmer histogram that should be 
	#easier and more memory effective for smudgeplot to use
	module load KMC/3.1.1
	mkdir -p tmp_${Seq}
	ls ../1_QCQA/${Seq}_R*_val_*.fq.gz > FILES
	#counting kmer coverages between 1 and 10000x
	echo $SLURM_MEM_PER_NODE and $((SLURM_MEM_PER_NODE/1024))
	kmc -k${kmer} -t$SLURM_NTASKS -m$((SLURM_MEM_PER_NODE/1024)) -ci1 -cs10000 @FILES ${Seq}_k${kmer}_counts tmp_${Seq}
	kmc_tools transform ${Seq}_k${kmer}_counts histogram ${Seq}_k${kmer}.hist -cx10000
	echo $(date): Done with KMC.
    else
	echo $(date): KMC has already been run, proceeding to smudgplot
    fi
done

#You must have smudgeplot installed. I am using v 0.2.1
export PATH="/rhome/arajewski/software:$PATH"
module load miniconda3

for Seq in ${GFP[@]}; do
    if [ ! -e ${Seq}_kmer_k${kmer}.dump ]; then
	echo $(date): Creating kmer dump file.
	L=$(smudgeplot.py cutoff ${Seq}_k${kmer}.hist L)
	U=$(smudgeplot.py cutoff ${Seq}_k${kmer}.hist U)
	echo $L $U # these need to be sane values
	# L should be like 20 - 200
	# U should be like 500 - 3000
	module load KMC/3.1.1
	kmc_tools transform ${Seq}_k${kmer}_counts -ci$L -cx$U dump -s ${Seq}_k${kmer}.dump
	echo $(date): Done.
    else
	echo $(date): Kmer dump file already created.
    fi
done

for Seq in ${GFP[@]}; do
    if [ ! -e ${Seq}_k${kmer}_pairs_coverages.tsv ]; then
	echo $(date): Running Smudgeplot
	smudgeplot.py hetkmers --middle -o ${Seq}_k${kmer}_pairs ${Seq}_k${kmer}.dump
	echo $(date): Done.
    else
	echo $(date): Smudgeplot hetkmers already completed.
    fi
done

for Seq in ${GFP[@]}; do
    if [ ! -e ${Seq}_${kmer}_smudgeplot.png ]; then
	echo $(date): Making smudgeplot itself.
	smudgeplot.py plot -k ${kmer} ${Seq}_k${kmer}_pairs_coverages.tsv -o ${Seq}_${kmer}
	echo $(date): Done
    else
	echo $(date): Smudgeplot already made.
    fi
done

scontrol show job $SLURM_JOB_ID
