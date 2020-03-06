#!/bin/bash -l
#SBATCH --ntasks=28
#SBATCH --nodes=1
#SBATCH --mem=101G
#SBATCH --time=20-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/loredec-%A.out
set -e
echo "${SLURM_ARRAY_JOB_ID}[${SLURM_ARRAY_TASK_ID}]"

module load loredec/0.9
module load boost
module load intel

#run DBG alone (9 hours with 24 CPUS and 101G)
if [ ! -e DstrTrim_k19_s3.h5 ]; then
echo $(date): Building Lordec de Bruijn graph...
lordec-build-SR-graph \
    -2 /rhome/arajewski/bigdata/Datura/1_hercules/DstrTrim_1P_subsample.fq,/rhome/arajewski/bigdata/Datura/1_hercules/DstrTrim_2P_subsample.fq \
    -k 19 \
    -s 3 \
    -t $SLURM_NTASKS \
    -g DstrTrim_k19_s3
echo $(date): done.
else
    echo $(date): Lordec de Bruijn graph already present.
fi

#Run the correction step with a bpre-built graph from above
if [ ! -e Dstr_Lordec.fasta ]; then
echo $(date): Running correction of nanopore reads...
lordec-correct \
    -i /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fasta \
    -2 DstrTrim \
    -k 19 \
    -s 3 \
    -t $SLURM_NTASKS \
    -o Dstr_Lordec.fasta
echo $(date): done.
else
echo $(date): Correction already complete.
fi

scontrol show job $SLURM_JOB_ID
