#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
##SBATCH --time 10-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/IPRScan-%A_%a.out
set -e

# This script is meant to be run as an array job with array IDs equal to the number of chunks the protein fasta was split into
WORKDIR=Dstr_v1.7_Annotation_largeIntrons_174/predict_results
NUMCHUNKS=6

# Check if IPR chunks were made
if [ ! -e $WORKDIR/Datura_stramonium.proteins.fa.$NUMCHUNKS ]; then
    echo $(date): Protein fasta file not split.
    if [ ! $SLURM_ARRAY_TASK_ID ] || [ $SLURM_ARRAY_TASK_ID == 1 ]; then
	echo $(date): Splitting protein fasta file into $NUMCHUNKS chunks...
	module load genometools
	gt splitfasta \
            --numfiles $NUMCHUNKS \
        $WORKDIR/Datura_stramonium.proteins.fa
	echo $(date): Done.
	echo $(date): Exiting. Please re-submit the job with array IDs = $NUMCHUNKS to run IPR Scan.
	exit 0
     else
	echo $(date): Array IDs larger than 1 are being cancelled to prevent spurious splitting.
	echo $(date): Once splitting is complete, re-run with array IDs = $NUMCHUNKS
	exit 0
     fi
elif [ ! -e $WORKDIR/IPRout.$NUMCHUNKS.xml ]; then
    echo $(date): Protein fasta already split.
    echo $(date): $NUMCHUNKS IPR result files not yet present.
    if [ ! $SLURM_ARRAY_TASK_ID ]; then
	echo $(date): Array ID not specified. Please re-submit with array IDs = $NUMCHUNKS to run IPR Scan.
	exit 1
    else
	echo $(date): Running IPR Scan on chunk $SLURM_ARRAY_TASK_ID of $NUMCHUNKS...
	module load iprscan
	module swap miniconda2 miniconda3
	interproscan.sh \
            -i $WORKDIR/Datura_stramonium.proteins.fa.$SLURM_ARRAY_TASK_ID \
            -f XML \
            -o $WORKDIR/IPRout.$SLURM_ARRAY_TASK_ID.xml \
            --goterms \
            -appl Pfam,TIGRFAM,PRINTS,ProSiteProfiles,CDD,SFLD,SignalP_EUK,Gene3D,SMART,SUPERFAMILY,MobiDBLite,Coils,TMHMM,PIRSF,PANTHER,Phobius \
            -dra \
            -cpu $SLURM_CPUS_PER_TASK
	echo $(date): Done.
	echo $(date): Please re-run without an array ID once all jobs have finished to combine results.
	exit 0
    fi
elif [ ! -e $WORKDIR/IPRout.final.xml ]; then
    echo $(date): Combined IPR results not yet present.
    if [ ! $SLURM_ARRAY_TASK_ID ] || [ $SLURM_ARRAY_TASK_ID == 1 ]; then
	echo $(date): Merging all $NUMCHUNKS IPR results XML files into IPRout.final.xml...
	grep -v "/protein-matches" $WORKDIR/IPRout.1.xml > $WORKDIR/IPRout.final.xml
	for ((c=2; c<="$NUMCHUNKS-1"; c++))
	do
            grep -v "protein-matches" $WORKDIR/IPRout.$c.xml | grep -v "xml " >> $WORKDIR/IPRout.final.xml
	done
	grep -v "xml " $WORKDIR/IPRout.$NUMCHUNKS.xml | grep -v "<protein-matches" >> $WORKDIR/IPRout.final.xml
	echo $(date): Done.
    else
	echo $(date): Array IDs larger than 1 are being cancelled to prevent spurious merging.
	exit 0
    fi
fi
