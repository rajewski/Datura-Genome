#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/RepeatModeler-%A.out
set -e

module load RepeatModeler/1.0.11
module load RepeatMasker/4-0-7
module load BBMap
module load ncbi-blast/2.2.30+
module load hmmer/3.1b2

# Download some tools to help parse
if [ ! -d Custom-Repeat-Library ]; then
    git clone https://github.com/megbowman/Custom-Repeat-Library.git
fi

# Remove short contigs in the assembly. I don't know if this is wise, but it might reduce runtime a bit and I can always include them later if this has the effect I want
if [ ! -e Dstr_v1.4.l250.fa ]; then
    reformat.sh in=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.4_ntEdit_edited.fa out=Dstr_v1.4.l250.fa minlength=250
fi

# Build Repeat Database
if [ ! -e Dstr_v1.4.nsq ]; then
    BuildDatabase -name Dstr_v1.4 -engine ncbi Dstr_v1.4.l250.fa
fi

# Classify them if possilbe
if [ ! -e RM_16353.ThuApr230853262020/consensi.fa.classified ]; then
    RepeatModeler \
	-database Dstr_v1.4 \
	-engine ncbi \
	-pa $SLURM_CPUS_PER_TASK 
fi

# Separate out unknown repeats
if [ !- e RepeatModeler_unknowns.fasta ]; then
    perl Custom-Repeat-Library/repeatmodeler_parse.pl \
	--fastafile RM_16353.ThuApr230853262020/consensi.fa.classified \
	--unknowns RepeatModeler_unknowns.fasta \
	--identities RepeatModeler_identities.fasta
fi

# Download and make database of known transposases for classification of unknowns
if [ ! -e Tpases020812.psq ]; then
    wget http://www.hrt.msu.edu/uploads/535/78637/Tpases020812.gz
    gunzip Tpases020812.gz
    makeblastdb -in Tpases020812  -dbtype prot
fi

# Attempt to classify unknown elements
if [ ! -e ModelerID.lib ]; then
    blastx -query RepeatModeler_unknowns.fasta -db Tpases020812  -evalue 1e-10 -num_descriptions 10 -out RepeatModeler_unknown_blast_results.txt
    perl Custom-Repeat-Library/transposon_blast_parse.pl --blastx RepeatModeler_unknown_blast_results.txt --modelerunknown RepeatModeler_unknowns.fasta
    mv  unknown_elements.txt  ModelerUnknown.lib
    cat identified_elements.txt  RepeatModeler_identities.fasta  > ModelerID.lib
fi

# Exclude hits that match a known (non-TE) protein
if [ ! -e ModelerUnknown.lib_blast_results.txt ]; then
    wget http://www.hrt.msu.edu/uploads/535/78637/alluniRefprexp070416.gz
    gunzip alluniRefprexp070416.gz
    makeblastdb -in alluniRefprexp070416  -dbtype prot
    blastx -query ModelerUnknown.lib -db alluniRefprexp070416  -evalue 1e-10 -num_descriptions 10 -out ModelerUnknown.lib_blast_results.txt
fi

# Install ProtExcluder
if [ ! -d ProtExcluder1.2 ]; then
    wget http://www.hrt.msu.edu/uploads/535/78637/ProtExcluder1.2.tar.gz
    tar -xf ProtExcluder1.2.tar.gz
    cd ProtExcluder1.2
    ./Installer.pl  -m  /opt/linux/centos/7.x/x86_64/pkgs/hmmer/3.1b2/bin/  -p /bigdata/littlab/arajewski/Datura/4_RepeatModeler/ProtExcluder1.2/
    echo You need to manually edit the mspesl-sfetch.pl hmmer path to say "bin" instead of "binaries"
fi

# Actually Run ProtExcluder on the BLAST results
if [ ! -e ModelerUnknown.libnoProtFinal ]; then
    ./ProtExcluder1.2/ProtExcluder.pl  ModelerUnknown.lib_blast_results.txt  ModelerUnknown.lib
fi

# Get all the repeats 
if [ ! -e FinalRepeats.fa ]; then
    queryRepeatDatabase.pl -species all > repeatmasker.all.fa
    cat ModelerUnknown.libnoProtFinal ModelerID.lib repeatmasker.all.fa > FinalRepeats.fa
fi
