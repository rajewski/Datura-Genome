#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
#SBATCH --time 5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/plantiSMASH-%A.out



OUTDIR=Dstr_v1.7_Annotation
ASSEM=$OUTDIR/predict_results/Datura_stramonium
FILTERED=Datura_stramonium.genicScaffolds.fa #filtered for only gene-contianing contigs

# Load the needed software
conda activate plantiSMASH
module load glimmer/3.02
module load glimmerhmm/3.0.4
#module load hmmer/2.3.2 #execuatable ares renamed and symlinked in plantismash dir
module load hmmer/3
module load fasttree/2.1.11 #2.1.7 tested
module load diamond/0.7.10
module load muscle/3.8.425 #3.8.31 tested
module load prodigal/2.6.2 #2.6.1 tested
module load ncbi-blast/2.2.31+
module load cd-hit/4.6.4 #4.6.6. tested
module unload miniconda3 

export PATH=/bigdata/littlab/arajewski/Datura/software/plantismash-1.0:$PATH

run_antismash.py \
    -c $SLURM_CPUS_PER_TASK \
    --limit -1 \
    --taxon plants \
    --eukaryotic \
    -v\
    --outputfolder $OUTDIR/plantismash \
    --genefinding none \
    --gff3 $ASSEM.gff3 \
    Datura_stramonium.genicScaffolds.fa
