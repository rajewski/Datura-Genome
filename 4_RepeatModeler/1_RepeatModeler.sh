#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/RepeatModeler-%A.out
set -e

module load RepeatModeler/1.0.11
module load RepeatMasker/4-0-7
module load BBMap
module load ncbi-blast/2.2.30+
module load hmmer/3.1b2

ASSEMNAME=Dstr_v1.7_final
ASSEMORIG=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.7_Iterative/Dstr_v1.7_lnr13_500bp_Sealer_ntEdit2_edited.fa

# Download some tools to help parse
if [ ! -d Custom-Repeat-Library ]; then
    echo $(date): Cloning Custom Repeat Library Scripts...
    git clone https://github.com/megbowman/Custom-Repeat-Library.git
    echo $(date): Done.
else
    echo $(date): Custom Repeat Library Scripts already present.
fi

# Download and make database of known transposases for classification of unknowns
if [ ! -e Tpases020812.psq ]; then
    echo $(date): Downloading Downloading and making database of transposases...
    wget http://www.hrt.msu.edu/uploads/535/78637/Tpases020812.gz
    gunzip Tpases020812.gz
    makeblastdb -in Tpases020812  -dbtype prot
    echo $(date): Done
else
    echo $(date): Transposase database already present.
fi

# Download and make uniprot database
if [ ! -e alluniRefprexp070416.psq ]; then
    echo $(date): Downloading and making UniProt database...
    wget http://www.hrt.msu.edu/uploads/535/78637/alluniRefprexp070416.gz
    gunzip alluniRefprexp070416.gz
    makeblastdb -in alluniRefprexp070416  -dbtype prot
    echo $(date): Done
else
    echo $(date): Uniprot database already present
fi

# Install ProExcluder
if [ ! -d ProtExcluder1.2 ]; then
    echo $(date): Downloading and installing ProtExcluder...
    wget http://www.hrt.msu.edu/uploads/535/78637/ProtExcluder1.2.tar.gz
    tar -xf ProtExcluder1.2.tar.gz
    cd ProtExcluder1.2
    ./Installer.pl  -m  /opt/linux/centos/7.x/x86_64/pkgs/hmmer/3.1b2/bin/  -p /bigdata/littlab/arajewski/Datura/4_RepeatModeler/ProtExcluder1.2/
    echo You need to manually edit the mspesl-sfetch.pl hmmer path to say "bin" instead of "binaries"
    echo $(date):Done.
else
    echo $(date): ProtExcluder already present.
fi

mkdir -p ${ASSEMNAME}_Repeats
cd ${ASSEMNAME}_Repeats

# Remove short contigs in the assembly. I don't know if this is wise, but it might reduce runtime a bit and I can always include them later if this has the effect I want
if [ ! -e $ASSEMNAME.fa ]; then
    echo $(date): Renaming assembly and length filtering...
    reformat.sh in=$ASSEMORIG out=$ASSEMNAME.fa minlength=250
    echo $(date): Done
else
    echo $(date): Target assembly $ASSEMNAME.fa already present and length filtered.
fi

# Build Repeat Database
if [ ! -e $ASSEMNAME.nsq ]; then
    echo $(date): Building repeat database of $ASSEMNAME.fa...
    BuildDatabase -name $ASSEMNAME -engine ncbi $ASSEMNAME.fa
    echo $(date): Done
else
    echo $(date): Repeat database already present.
fi

# Classify them
# Check if we've alreayd started this
if [ ! -e RM* ]; then
    echo $(date): Running RepeatModeler of $ASSEMNAME with $SLURM_CPUS_PER_TASK cores...
    RepeatModeler \
        -database $ASSEMNAME \
        -engine ncbi \
        -pa $SLURM_CPUS_PER_TASK
    echo $(date): Done.
# If it's been started, find the most recent attempt
else
    RepeatDir=$(ls -td -- RM*/ | head -n 1)
    # Did the most recent attempt finish the first round?
    if [ ! -d $RepeatDir/round-2/ ]; then
	echo $(date): Running RepeatModeler of $ASSEMNAME with $SLURM_CPUS_PER_TASK cores...
	RepeatModeler \
            -database $ASSEMNAME \
            -engine ncbi \
            -pa $SLURM_CPUS_PER_TASK
	echo $(date): Done.
    # If the first round is finished, did everything finish?
    elif [ ! -e $RepeatDir/consensi.fa.classified ]; then
	echo $(date): Restarting RepeatModeler of $ASSEMNAME with $SLURM_CPUS_PER_TASK cores...
        RepeatModeler \
            -database $ASSEMNAME \
            -engine ncbi \
            -pa $SLURM_CPUS_PER_TASK \
	    --recoverDir $RepeatDir
        echo $(date): Done.
    # If the final file is found, just skip this
    else
	echo $(date): RepeatModeler already run.
    fi
fi

# Separate  out unknown repeats
if [ ! -e RepeatModeler_unknowns.fasta ]; then
    echo $(date): Parsing RepeatModeler output into known and unknown repeats...
    perl ../Custom-Repeat-Library/repeatmodeler_parse.pl \
	--fastafile RM_*/consensi.fa.classified \
	--unknowns RepeatModeler_unknowns.fasta \
	--identities RepeatModeler_identities.fasta
    echo $(date): Done
else
    echo $(date): RepeatModeler output already parsed.
fi

# Attempt to classify unknown elements
if [ ! -e ModelerID.lib ]; then
    echo $(date): Classifying repeat elements...
    blastx \
	-query RepeatModeler_unknowns.fasta \
	-db ../Tpases020812  \
	-evalue 1e-10 \
	-num_descriptions 10 \
	-out RepeatModeler_unknown_blast_results.txt
    perl ../Custom-Repeat-Library/transposon_blast_parse.pl --blastx RepeatModeler_unknown_blast_results.txt --modelerunknown RepeatModeler_unknowns.fasta
    mv  unknown_elements.txt  ModelerUnknown.lib
    cat identified_elements.txt  RepeatModeler_identities.fasta  > ModelerID.lib
    echo $(date): Done
else
    echo $(date): Repeat elements already classified.
fi

# Exclude hits that match a known (non-TE) protein
if [ ! -e ModelerUnknown.lib_blast_results.txt ]; then
    echo $(date): Finding non-TE hits in repeat elements...
    blastx \
	-query ModelerUnknown.lib \
	-db ../alluniRefprexp070416  \
	-evalue 1e-10 \
	-num_descriptions 10 \
	-out ModelerUnknown.lib_blast_results.txt
    echo $(date): Done
else
    echo $(date): Non-TE hits already detected.
fi

#  Run ProtExcluder on the BLAST results
if [ ! -e ModelerUnknown.libnoProtFinal ]; then
    echo $(date): Running ProtExcluder to remove non-TE hits...
    ../ProtExcluder1.2/ProtExcluder.pl  ModelerUnknown.lib_blast_results.txt  ModelerUnknown.lib
    echo $(date): Done
else
    echo $(date): Non-TE hits already removed.
fi

# Get all the repeats 
if [ ! -e FinalRepeats.fa ]; then
    echo $(date): Querying repeat database to get all repeats
    queryRepeatDatabase.pl -species all > repeatmasker.all.fa
    cat ModelerUnknown.libnoProtFinal ModelerID.lib repeatmasker.all.fa > FinalRepeats.fa
    echo $(date): Done
else
    echo $(date): Done. Like done for real.
fi
