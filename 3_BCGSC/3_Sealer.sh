#!/bin/bash -l
#SBATCH --cpus-per-task=30
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Sealer-%A.out
set -e

#Get env right
module load ABYSS/2.0.2
ASSEM=Dstr_v1.7_lnr13_500bp.fa
ASSEMDIR=Dstr_v1.7_Iterative
ASSEMBASE=$(echo $ASSEM | sed 's/\.fa//g')
gaps=(40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125)

for i in ${gaps[@]}
do
    echo $(date): Running Sealer with k=$i...
    # Check that this iteration hasn't already completed.
    if [  -s $ASSEMDIR/${ASSEMBASE}_Sealer_k${i}_scaffold.fa ]; then
	echo Sealer has already been run with k=$i. Skipping to next k.
	continue
    fi
    # Change flank size with large k values
    if [ $i -ge 95 ]; then
	echo Large value detected for k, increasing flank size to 150bp.
	flank=150
    else
	flank=100
    fi
    # Set the input file name on anything but the first round
    if [ $i -ge ${gaps[1]} ]; then
	((last=$i-5))
	ASSEM=${ASSEMBASE}_Sealer_k${last}_scaffold.fa
    fi
    # run SEALER for this k value
    # with pre-built bloom filters from 3a_BloomBuild.sh                                                                                                                                              
    abyss-sealer \
	-v \
	-j $SLURM_CPUS_PER_TASK \
	-s 7G \
	-b40G \
	-L $flank \
	-k$i \
	-i Bloomfilters/k$i.bloom \
	-G 2000 \
	-o $ASSEMDIR/${ASSEMBASE}_Sealer_k${i} \
	-S $ASSEMDIR/$ASSEM
    echo $(date): Done with k=$i
done
