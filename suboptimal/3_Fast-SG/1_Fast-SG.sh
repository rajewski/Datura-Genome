#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATHC --cpus-per-task=16
#SBATCH --mem-per-cpu=7G
#SBATCH --time=05:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Fast-SG-%A.out
set -eu

#This will take as input the assembly, create aritficial large insert libraries from the nanopore data with Fast-SG
module load KMC/3.1.1
ASSEMBLY=/rhome/arajewski/bigdata/Datura/2_MaSuRCA338/flye/assembly.fasta

#Index assembly if necessary
if [ ! -e $ASSEMBLY.fai ]; then
    echo $(date): indexing $ASSEMBLY
    module load samtools
    samtools faidx $ASSEMBLY
    echo $(date): Finished.
else
    echo $(date): Found index of $ASSEMBLY.
fi

#Rename nanopore reads
if [ ! -e /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr_Lordec.Renamed.fasta.gz ]; then
    echo $(date): Renaming ONT reads.
    awk 'BEGIN{h=1;s=2;i=1}{if(NR==h){print ">ONT_"i; h+=2;i++;} if(NR == s){print $0; s+=2;}}'  /rhome/arajewski/bigdata/Datura/1_Loredec/Dstr_Lordec.fasta | fold | gzip > /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr_Lordec.Renamed.fasta.gz
    echo $(date): Finished.
else
    echo $(date): ONT reads already renamed.
fi

#need to make tmp directory manually "Dstr_v1.3_k101.kmctmp.K22"
#consider with a different value for K
/rhome/arajewski/bigdata/Datura/software/fastsg/FAST-SG.pl \
    -k 22 \
    -l ultra-long-conf.txt \
    -r $ASSEMBLY \
    -p Dstr_v1.5 \
    -t 16 > Dstr_v1.3.fastsg.log

scontrol show job $SLURM_JOB_ID
