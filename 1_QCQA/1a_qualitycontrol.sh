#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=7G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Trim-%A.out
set -e
# Trim with Trim_Galore to remove low quality bases and adaptor sequences
module unload perl
module swap miniconda2 miniconda3
module swap python/2.7.5 python/3.6.0
module load fastqc
conda activate cutadaptenv
export PATH=/bigdata/littlab/arajewski/Datura/software/TrimGalore-0.6.5:$PATH

#Pass a list of PE vs SE datasets
PAIRS=( Alex_S85_L002 Alex_S230_L002 )
SINGLES=( Alex-1_S9 Alex-2_S10 )
DNAPATH=/bigdata/littlab/arajewski/Datura/DNA-seq
#Do PE data
for i in ${!PAIRS[@]}
do
if [ ! -e ${PAIRS[i]}_R2_001_val_2.fq.gz ]; then
    echo Running Trim Galore on ${PAIRS[i]}...
    trim_galore \
        --paired \
	-j $SLURM_CPUS_PER_TASK \
        -o ./ \
        --no_report_file \
        $DNAPATH/${PAIRS[i]}_R1_001.fastq.gz $DNAPATH/${PAIRS[i]}_R2_001.fastq.gz 
    echo Done.
else
    echo ${PAIRS[i]} already trimmed.
fi
done

# Do SE data
for i in ${!SINGLES[@]}
do
if [ ! -e ${SINGLES[i]}_R1_001_trimmed.fastq.gz ]; then
    echo Running Trim Galore on ${SINGLES[i]}...
    trim_galore \
        -o ./ \
        --no_report_file \
	-j $SLURM_CPUS_PER_TASK \
        $DNAPATH/${SINGLES[i]}_R1_001.fastq.gz 
    echo Done.
else
    echo ${SINGLES[i]} already trimmed.
fi
done

# symlink to trimmed files for easier referencing later
ln -sf ${PAIRS[0]}_R1_001_val_1.fq.gz PE1_1.fq.gz
ln -sf ${PAIRS[0]}_R2_001_val_2.fq.gz PE1_2.fq.gz
ln -sf ${PAIRS[1]}_R1_001_val_1.fq.gz PE2_1.fq.gz
ln -sf ${PAIRS[1]}_R2_001_val_2.fq.gz PE2_2.fq.gz
ln -sf ${SINGLES[0]}_R1_001_trimmed.fq.gz SE1.fq.gz
ln -sf ${SINGLES[1]}_R1_001_trimmed.fq.gz SE2.fq.gz

