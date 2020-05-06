#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=7G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Trim-%A.out
set -euv

# Trim with Trim_Galore to remove low quality bases and adaptor sequences
module unload perl
module unload miniconda2
module load trim_galore/0.4.2

#Pass a list of PE vs SE datasets
PAIRS=( Alex_S85_L002 Alex_S230_L002 )
SINGLES=(Alex-1_S9 Alex-2_S10 )
DNAPATH=/bigdata/littlab/arajewski/Datura/DNA-seq
#Do PE data
for i in ${!PAIRS[@]}
do
if [ ! -e '${PAIRS[i]}_val_2.fq.gz' ]; then
    echo Running Trim Galore on ${PAIRS[i]}...
    trim_galore \
        --paired \
        -o ./ \
        --no_report_file \
        $DNAPATH/${PAIRS[i]}_R1_001.fastq.gz $DNAPATH/${PAIRS[i]}_R1_001.fastq.gz 
    echo Done.
else
    echo ${PAIRS[i]} already trimmed.
fi
done

# Do SE data
for i in ${!SINGLES[@]}
do
if [ ! -e '${SINGLES[i]}_R1_001_trimmed.fastq.gz' ]; then
    echo Running Trim Galore on ${SINGLES[i]}...
    trim_galore \
        -o ./ \
        --no_report_file \
        $DNAPATH${SINGLES[i]}_R1_001.fastq.gz 
    echo Done.
else
    echo ${SINGLES[i]} already trimmed.
fi
done
