#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=40G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Fast-SG-%A.out
set -eu

#This will take as input the assembly, create aritficial large insert libraries from the nanopore data with Fast-SG
module load KMC/3.1.1
ASSEMBLY=/rhome/arajewski/bigdata/Datura/2_ABySS/k_101/Dstr_v1.3_k101-scaffolds.fa

#Index assembly if necessary
if [ ! -e $ASSEMBLY.fai ]; then
    echo $(date): indexing $ASSEMBLY
    module load samtools
    samtools faidx $ASSEMBLY
    echo $(date): Finished.
else
    echo $(date): Found index of $ASSEMBLY.
fi

#should really try without this step or with a lower threshold
#Extracting only reads longer than 2kb
if [ ! -e $ASSEMBLY.2kb.fa ]; then
    echo $(date): Extracting contigs larger than 2kb.
    sort -rn -k2,2 $ASSEMBLY.fai | awk '{if($2 >=2000){print $1}}' > $ASSEMBLY.2kb.lst
    samtools faidx $ASSEMBLY $(cat $ASSEMBLY.2kb.lst | xargs) > $ASSEMBLY.2kb.fa
    echo $(date): Finished.
else
    echo $(date): Large contigs already extracted to $ASSEMBLY.2kb.fa
fi

#Rename nanopore reads
if [ ! -e /rhome/arajewski/bigdata/Datura/1_QCQA/ULTRA-LONG-RENAME-FOLD.fa.gz ]; then
    echo $(date): Renaming ONT reads.
    zcat /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq.gz | awk 'BEGIN{h=1;s=2;i=1}{if(NR==h){print ">ONT_"i; h+=4;i++;} if(NR == s){print $0; s+=4;}}' | fold | gzip > /rhome/arajewski/bigdata/Datura/1_QCQA/ULTRA-LONG-RENAME-FOLD.fa.gz
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
    -p Dstr_v1.3_k101_z100 \
    -t $SLURM_NTASKS > Dstr_v1.3.fastsg.log

scontrol show job $SLURM_JOB_ID
