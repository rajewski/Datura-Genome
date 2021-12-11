#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/getOrganelle-%A.out

module load mafft/7.471

cat NC_018117.1.fasta 20201009_Ref_plastome/embplant_pt.K105.complete.graph1.1.path_sequence.fasta 20201009_Ref_plastome/embplant_pt.K105.complete.graph1.2.path_sequence.fasta > Dstr_cp2.fasta

mafft \
    --thread $SLURM_CPUS_PER_TASK \
    --nomemsave \
    Dstr_cp2.fasta > Dstr_cp2.align.fasta

