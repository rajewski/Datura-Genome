#!/bin/bash -l
#SBATCH --ntasks=14
#SBATCH --nodes=1
#SBATCH --mem=175G
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/slurm-%A.out
set -euv
FQ=../1_QCQA/*.fq.gz
ShortFQ='DstrTrim'

module load jellyfish/2.2.9
zcat $FQ | jellyfish count -m $SLURM_ARRAY_TASK_ID -s 2014M --min-qual-char=? -t $SLURM_NTASKS -C -o Results_AllTrim/$ShortFQ'_'$SLURM_ARRAY_TASK_ID'mer_counts.jf' /dev/fd/0
jellyfish histo -t $SLURM_NTASKS -o Results_AllTrim/$ShortFQ'_'$SLURM_ARRAY_TASK_ID'mer_out.histo' Results_AllTrim/$ShortFQ'_'$SLURM_ARRAY_TASK_ID'mer_counts.jf'
rm Results_AllTrim/$ShortFQ'_'$SLURM_ARRAY_TASK_ID'mer_counts.jf'

