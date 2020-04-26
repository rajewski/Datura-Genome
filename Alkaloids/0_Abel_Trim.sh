#!/bin/bash -l
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
#SBATCH --time=6:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/TrimGalore-%A.out
set -eu

module unload perl
module unload miniconda2
module unload python/2.7.5
module load python/3.6.0
module load trim_galore/0.4.2

#Pass a list of PE vs SE datasets
PAIRS=(ERR2040625 SRR118430 SRR192881 SRR9888536 SRR192882 SRR118431)
SINGLES=(SRR118439 SRR118440 SRR118438 SRR118432 SRR118435 SRR118436 SRR118437 SRR118433 SRR118429 SRR118441 SRR118434) 

#Do PE data
for PESRA in ${PAIRS[@]}; do
    if [ ! -e Abel_trinity/${PESRA}_2_val_2.fq.gz ]; then
	echo Running Trim Galore on $PESRA. ...
	trim_galore \
	    --paired \
	    -o Abel_trinity \
	    --no_report_file \
            ExternalData/Abel/${PESRA}_*.fastq.gz 
	echo Done.
    else
	echo $PESRA RNA seq already trimmed.
    fi
done

#Do SE data
for SESRA in ${SINGLES[@]}; do
    if [ ! -e Abel_trinity/${SESRA}_1_trimmed.fq.gz ]; then
        echo Running Trim Galore on $SESRA. ...
        trim_galore \
            -o Abel_trinity \
            --no_report_file \
            ExternalData/Abel/${SESRA}_1.fastq.gz
        echo Done.
    else
        echo $SESRA RNA seq already trimmed.
    fi
done

