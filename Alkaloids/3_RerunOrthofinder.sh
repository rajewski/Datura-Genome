#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Orthofinder-%A.out
set -e

# Make symlinks for all the protein fasta files without glycine max (use species.tsv to include soy)
mkdir -p Orthologies
echo $(date): Making symlinks
while read ABBREV LOCATION
do
    ln -sf $LOCATION ./Orthologies/$ABBREV.fasta
done < ./species_Soyless.tsv
echo $(date): Done

echo $(date): loading modules...
module load orthofinder/2.4.0
module load mafft/7.427
module load IQ-TREE/1.6.12
echo$(date): Done.

echo $(date): actually running Orthofinder...

orthofinder \
   -t $SLURM_CPUS_PER_TASK \
   -b ./Orthologies/OrthoFinder/Results_Sep28/WorkingDirectory/ \
   -f ./Orthologies

echo $(date): Done.
