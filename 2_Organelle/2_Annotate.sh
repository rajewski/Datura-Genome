#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/getOrganelle-%A.out


PATH=/bigdata/littlab/arajewski/Datura/software/PGA/:$PATH
module load ncbi-blast/2.2.30+
# it only takes directories, so jfc lemme make them
mkdir -p PGA_ref
mkdir -p PGA_target
ln -sf ../NC_018117.1.gb PGA_ref/NC_018117.gb
ln -sf ../20201009_Ref_plastome/embplant_pt.K105.complete.graph1.2.path_sequence.fasta PGA_target/embplant_pt.K105.complete.graph1.2.path_sequence.fasta

PGA.pl \
    -r PGA_ref \
    -t PGA_target \
    -o PGA_out
