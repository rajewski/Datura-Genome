#!/bin/bash -l
#SBATCH --ntasks=8
#SBATCH --nodes=1
#SBATCH --mem=10G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p batch
#SBATCH -o history/slurm-%A.out
set -euv

# $((SLURM_MEM_PER_NODE/1000))'G'
# $SLURM_NTASKS

#Use fastqc to get a quality report of the input

if [ ! -d "QualityControl" ]; then
    echo $(date) ": Running fastqc."
    module load fastqc/0.11.7
    fastqc -t $SLURM_NTASKS -noextract -o 1_QCQA DNA-seq/*.fastq.gz
    echo $(date) ": Done."
else
    echo $(date) ": fastqc has already been run. Let's trim and filter these reads."
fi

#use trimmomatic to trim out low quality bases and adaptor sequences
#I cannot automate this with a loop because the file names are inconsistent. I could rename, but I want to preserve the original names for troubleshooting later
module load trimmomatic/0.36

#I'll add in an if statement once I know exactly how the outputs are structured so that I can check for them accurately.
trimmomatic PE -threads $SLURM_NTASKS DNA-seq/Alex-1_S9_R1_001.fastq.gz DNA-seq/Alex-2_S10_R1_001.fastq.gz -baseout DNA-seqTrimmed/Dstr1Trim.fq.gz ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
#trimmomatic PE -threads $SLURM_NTASKS DNA-seq/Alex_S230_L002_R1_001.fastq.gz DNA-seq/Alex_S230_L002_R2_001.fastq.gz -baseout DNA-seqTrimmed/Dstr2Trim.fq.gz
#trimmomatic PE -threads $SLURM_NTASKS DNA-seq/Alex_S85_L002_R1_001.fastq.gz DNA-seq/Alex_S85_L002_R2_001.fastq.gz -baseout DNA-seqTrimmed/Dstr3Trim.fq.gz

