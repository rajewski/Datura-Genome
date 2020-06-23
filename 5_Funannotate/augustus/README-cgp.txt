# manual for AUGUSTUS in comparative gene prediction (cgp) mode
# genes are predicted simulteneously in several aligned genomes
# Stefanie Koenig, September 25th, 2015

 1. INTRODUCTION
 2. DEPENDENCIES
 3. INSTALLATION
 4. RUNNING AUGUSTUS IN CGP MODE
 5. OPTIONAL ARGUMENTS
 6. RETRIEVING GENOMES FROM A MYSQL DATABASE
 7. USING HINTS
 8. SQLITE ACCESS
 9. TRAINING OF CLADE-SPECIFIC PARAMETERS (USUALLY NOT REQUIRED!!!)
10. BUILDING THE NEWICK PARSER FROM SCRATCH
    (not needed unless you run into compiler errors related to 'parse.cc' or 'lex.cc')
11. TRAINING CGP SCORE PARAMETERS 

1. INTRODUCTION
----------------
The cgp mode is an extension to AUGUSTUS that takes an alignment of two or more genomes
and simultaneously predicts genes in all of them.
Beside the genomes and the alignment, a phylogenetic tree of the species is required input.
AUGUSTUS-cgp can either be used

- de novo, or
- with extrinsic evidence for any subset of species
  Such evidence includes for example already existing and trusted gene structures or hints from RNA-Seq alignments.


Both genomes and extrinsic evidence can either be read in from a flat file or 
alternatively retrieved from a MYSQL or SQLITE database.
All three approaches are described below in more detail.

This manual assumes that you are already familiar with AUGUSTUS
and that you know how to use AUGUSTUS for gene prediction in a single genome.

2. DEPENDENCIES
-----------------

The following programs need be installed in cgp mode:

- GSL (GNU Scientific Library)
- Boost C++ Libraries (>= V1_46_1)
- g++ compiler with C++0X support (>= V4.4)
- lpsolve (mixed linear integer programming)

3. INSTALLATION
----------------

a) install all dependencies

   GSL:      use package manager or install from source from http://www.gnu.org/software/gsl/
   Boost:    install via package manager, on UBUNTU/Debian linux:
             > sudo apt-get install libboost-all-dev
   g++       install via package manager:
             > sudo apt-get install build-essential
   lpsolve   > sudo apt-get install libsuitesparse-dev liblpsolve55-dev 

  optional (for gzipped input):
   zlib:     The compression library. Download from http://www.zlib.net/ or install via package manager.

b) recompile AUGUSTUS with cgp mode enabled

   open the file common.mk with a text editor and uncomment the following line to enable comparative gene prediction

#COMGENEPRED = true

   recompile AUGUSTUS

>  cd src
>  make clean all

  
4. RUNNING AUGUSTUS IN CGP MODE
--------------------------------  
   
In order to call AUGUSTUS in the comparative gene prediction mode, 4 mandatory arguments need to be passed:

--species=identifier
          a species for which model parameters are trained. For a list of identifiers see README.txt.
	  Decide on one of the species in your set that you can find in the list of identifiers or that
          comes closest to one of the identifiers. For instance, use the identifier 'human' for a mammal
          data set or the identifier 'chicken' for a bird data set
	  

--speciesfilenames=genomes.tbl
                   a file containing for each species the path to its genome file.
		   Each line in 'genomes.tbl' consists of two tab-separated fields.
		   The first field is a species identifier (does not correspond to the
		   identifier in --species !!!).
		   The second field is the directory and file name for the genome file, e.g.
                   
hg19	 /dir/to/genome/human.fa
rheMac2	 /dir/to/genome/rhesus.fa
mm9	 /dir/to/genome/mouse.fa
bosTau4	 /dir/to/genome/cow.fa
galGal3	 /dir/to/genome/chicken.fa

		   The genome files must be in fasta format and may contain the sequences of one or more chromosomes/scaffolds.
		   The file 'mouse.fa' might look as follows

>chr16
AGCTCGCAGTGTTGATGCTTCAGTCTC
>chr3
ccagaggagacagttagtactaaatgcaccaa
   
                   For running Augustus-cgp on a subset of genomes, simply delete all lines of non-target genomes in --speciesfilenames.
		   The alignment and phylogenetic tree need no modification.

--alnfile=aln.maf
          a file containing a multiple sequence alignment of the genomes in MAF format.
          The sequence names (first field in an 's' line) must be the species identifiers (as they appear in 'genomes.tbl')
          and the sequences identifiers (as they appear in  the genome files) delimited by '.', e.g.  

a score=235085.000000
s hg19.chr21                        15725769 27 +  48129895 AGCTATTGCTGTTTATGTCTCAATTTC
s rheMac2.chr3                     163875558 27 - 196418989 AGCTCTTGCTGTTTACGTCTCGATTTC
s mm9.chr16                         75744509 27 +  98319150 AGCTCGCAGTGTTGATGCTTCAGTCTC
s bosTau4.chr1                     138520043 27 - 161106243 AGCTATTGATGTTTATGTCTTCATTTC
s galGal3.chr1                     101466793 21 + 200994015 AGCTCGAGAAG------AGCCATTATA

a score=128487.000000
s hg19.chr21                        15725796 32 +  48129895 CCAGAGGAGAGGGTTAGTACCAAATGCACCAA
s bosTau4.chr1                     138520070 30 - 161106243 CCAGAGGAGA--GTTCATATTGAGTGCACCAA
s mm9.chr16                         75744536 30 +  98319150 TCAGAGAAGA--ACTTGGACAAAGTGCACCCA
s rheMac2.chr3                     163875585 32 - 196418989 CCAGAGGAGACAGTTAGTACTAAATGCACCAA

         Alignment rows of species that are not listed in --speciesfilenames are ignored.
         
--treefile=tree.nwk
           a phylogenetic tree of the species in Newick format, e.g.   

((((hg19:0.032973,rheMac2:0.036199):0.129706,mm9:0.352605):0.020666,bosTau4:0.219477):0.438357,galGal3:0.474279);

           All branch lengths are required and leaf nodes must be named after the species identifier (as
           in 'aln.maf' and 'genomes.tbl'). Also a valid format (often output of phylogenetic
           tree reconstruction tools such as MrBayes, PHYLIP, ...)  is f.i.

begin trees;
        translate
                1       hg19,
                2       rheMac2,
                3       mm9,
                4       bosTau4,
                5       galGal3
                ;
tree con_50_majrule = [&U] ((((1:0.032973,2:0.036199):0.129706,3:0.352605):0.020666,4:0.219477):0.438357,5:0.474279);
end;

           In cases where the phylogeny is not known, a star-like tree with uniform branch lengths might be used instead, e.g.

(hg19:0.01,rheMac2:0.01,mm9:0.01,bosTau4:0.01,galGal3:0.01);

           If --speciesfilenames only contains a subset of the species in --treefile, a subtree of is extracted.

example usage:

> augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --speciesfilenames=genomes.tbl

a small data set for testing can be found in examples/cgp/


5. OPTIONAL ARGUMENTS
------------------------

a) General Options:
-------------------

--/CompPred/onlySampledECs=on/off
  if on, only exons from the sampling of gene structures are taken as the set of possible candidate exons.
  Otherwise additional candidate exons are determined by combining all possible pairs of ASS/DSS
  start/DSS, ASS/stop and start/stop that are within the maximum length of exons (--max_exon_len, default: 12000).
  Turn this flag on, to reduce the overall runtime memory requirements (default: off)

--/CompPred/liftover_all_ECs=on/off
  by default only likely exon candidates (the ones from sampling) are lifted over to
  the other genomes. If this flag is turned on ALL exon candidates are lifted over to
  the other genomes. This increases the runtime and memory requirement, but is potentially
  more accurate (default: off)

--UTR=on/off
  predict the untranslated regions in addition to the coding sequence.
  Note that the 3'-UTR, 5'UTR or both can be absent in some genes if candidate UTRs
  perform poorly in the ab initio model and are not supported by extrinsic evidence. Enforce the prediction
  of UTRs with --/CompPred/genesWithoutUTRs=false

--nc=on/off
  simultaneous prediction of coding genes and non-coding genes (mostly lincRNA) (default: off)
  Non-coding genes are only predicted if they have RNA-Seq support.
  This option is experimental, as the scores of exons/introns of non-coding genes in the gene structure graph still need to be defined.
  Usage only intended for developers!

--genemodel=partial/complete
  partial      : allow prediction of incomplete genes at the sequence boundaries (default)
  complete     : only predict complete genes

--/CompPred/genesWithoutUTRs=true/false
  if true, all predicted genes are flanked by a 5'- and 3'- untranslated region (with the exception of partial genes at the sequence boundaries).
  this option only makes sense together with --UTR=on.

--noprediction=true/false
  If true, no prediction is made. Useful for getting the gene ranges and homologous candidate exons.

--/CompPred/outdir=path
  send all output files to this directory (default is the current directory)

--printOEs=true/false
  print all homologous candidate exons to the file orthoExons.<species>.gff3 (default: off)

--/CompPred/printOrthoExonAli=true/false
   prints codon alignments of all tuples of homologous candidate exons to the file 'orthoexons_codonAlignment.maf'
   (default: false)

--/CompPred/printConservationWig=true/false
  prints conservation tracks (in wiggle format) of all syntenic regions to the file <species>.wig
  (default: off)

--exoncands=true/false
  print all candidate exons to the file exonCands.<species>.gff3 (default: off)

--softmasking=1
 adds regions with lowercase nucleotides as nonexonpart hints of source "RM"
 If --extrinsicCfgFile is not given, it used the default cgp.extrinsic.cfg with bonus 1.15, if 
 another extrinsic config file is given, it must contain the "RM" source.

--temperature=t
  heat the posterior distribution for sampling, 0=cold, 7=hottest, take probs to the power of (8-temperature)/8
  (default: 3)

--optCfgFile=cgp_parameters.cfg
  include parameter file from training. The training uses logistic regression to classify candidate exons
  based on cross-species features like selective pressure (dN/dS), conservation, phylogenetic diversity, etc.
  (default: config/cgp/log_reg_parameters_default.cfg)

--allow_hinted_splicesites=atac
  comma-separated list of non-canonical splice site pairs that enables the prediction of rare introns with
  unusual splice sites in addition to the GT-AG and GC-AG introns that are allowed by default.
  

b) Options to adjust the generation of geneRanges (syntenic regions) from the input alignment
---------------------------------------------------------------------------------------------

--maxDNAPieceSize=n
  This value specifies the maximal length of a sequence chunk in a geneRange. For longer sequence chunks, the
  geneRange is cut into several pieces that are processed separately. (default: 200000)

--/CompPred/maxCov
  Decreasing maxCov punishes multiple overlapping geneRanges more.
  By default, maxCov = 3 penalizes the same region covered by more than 3 alignments

--/CompPred/covPen
  Increasing the coverage penalty covPen punishes long overlaps between geneRanges more.
  By default, covPen = 0.2 punishes uncovered bases 5 times more than each base covered too often


c) Options to adjust properties of splice sites, exons, introns and genes
-------------------------------------------------------------------------

--max_exon_len=n
  maximum length of a candidate exon (default: 12000)

--min_intron_len=n
  minimum length of a candidate intron (default: 39)

--min_coding_len=n
  minimum length of a coding region (default: 102)

--/CompPred/mil_factor=f
  mean intron length factor (>=1), the higher the less are long introns penalized (default: 1).
  A value of 100 roughly corresponds to not penalizing long introns.
  (does not concern explicit introns from sampling whose lengths are modeled explicitly by a geometric-tail
  distribution. This only concerns implicit introns that are constructed along auxiliary bars in the gene structure graph).

--/CompPred/dssqthresh=q
  threshold for the inclusion of donor splice sites based on the pattern probability (q in [0,1] )
  q=0.05 means that only dss are considered that have a pattern, such that 5% of true splice site patterns have lower probability.
  q=0 means that all splice site patterns are considered.

--/CompPred/assqthresh=q --/CompPred/assmotifqthresh=q
  thresholds for the inclusion of aceptor splice sites
  (the inclusion of an acceptor splice site depends both on the ASS and the ASS motif threshold)

  
d) Options to adjust the scoring function of candidate exons/introns:
---------------------------------------------------------------------

--/CompPred/omega=on/off
  estimate selective pressure (non-synonymous to synonymous rate ration dN/dS) for each codon alignment
  of homologous candidate exons (default: on)

--/CompPred/conservation=on/off
  compute an average columnwise conservation score for each tuple of homologous candidate exons (default: on)

--/CompPred/ec_thold=a
  parameter that is added to the scoring function of candidate exons (default: 0). Enables the shifting
  of the scoring function such that sensitivity (SN) and specificity (SP) are in balance.
  If t>0 is the threshold from logistic regresission for which SN and SP are in balance on the training
  set, then set
  a = log((1/t) - 1)
   
--/CompPred/ic_thold=b
  parameter that is added to the scoring function of candidate introns (default: 0).
  Analogous to parameter --/CompPred/ec_thold above.

--/CompPred/scale_codontree=f
  scaling factor to scale branch lengths in the codon tree to one codon substitution per time unit
  (default: 1)


e) Options to adjust the phylogenetic model:
--------------------------------------------

--/CompPred/phylo_model=2,3 or 4
  number of states in the phylogenetic model (default: 2)
  model 2: state 1: EC present but not predicted
           state 2: EC present and predicted
	   rate Matrix Q = [(-lambda, lambda), (mu, -mu)]
	   depends on parameters --/CompPred/exon_gain (lambda) and --/CompPred/exon_loss (mu)
	   (see next parameters)	   
  model 3: model 2 + state 3: EC not present but alignment present
           additionally depends on --/CompPred/ali_error
	   (see next parameters)
  model 4: model 3 + state 4: no alignment present
  models 3 and 4 are experimental as the rate matrices are not well defined.
  (usage only recommended for developers that want to play around with the rate matrices)

--/CompPred/exon_loss=r
  rate r>0 of exon loss (parameter of the phylogenetic models, see above)
  (default: )

--/CompPred/exon_loss=r
  rate r>0 of exon gain (parameter of the phylogenetic models, see above)
  (default: )

--/CompPred/ali_error=r
  rate r of alignment errors (parameter of the phylogenetic model 3 and 4, see above)

--/CompPred/phylo_factor=f
  specifies the influence of the phylogenetic model (default: 1).
  The higher f is chosen, the more weight is given to the phylogenetic model, i.e.
  the more consistent the gene structures are across the species.
  

f) Options to adjust the DD algorithm:
--------------------------------------

--/CompPred/dd_rounds=r
  the number of Dual Decomposition rounds (default: 5).

--/CompPred/maxIterations=n
  the maximum number of Dual Decomposition iterations per round (default: 500).

--/CompPred/dd_step_rule=harmonic/square_root/base_2/base_e/polyak/constant/mixed
  the step size function (default: mixed)
  - constant:       c
  - harmonic:       c / (v+1)
  - square_root:    c / sqrt(v+1)
  - base_2:         c / (2^v)
  - base_6:         c / (e^v)
  - polyak:         (d_t - p_best) / numInconsistencies
  - mixed:          1. round: polyak, all other rounds: square_root
  where c is the step size parameter (see next parameter) and v is the number of iterations prior
  to the current iteration, in which the value of the dual problem increases. The polyak step
  size adjusts the step size dynamically from quantities computed in previous iterations:
  d_t is the current dual value, p_best is the best primal value, seen so far and
  numInconsistencies is the current number of inconsistencies between the complicating variables.

--/CompPred/dd_factor=a-b
  value range of the step size parameter c (default: 1-4). Only required for step size rules other than "polyak".
  When only a single round of DD (--/CompPred/dd_rounds=1) is chosen, specify a single value for the step size parameter,
  e.g. --/CompPred/dd_factor=a. For r>1 rounds of DD, the value range [a-b] is split into r equidistant values,
  e.g. for r=4, a=1 and b=4, the values 1,2,3 and 4 are used for the first, second, ... and fourth round of DD, respectively.


6. RETRIEVING GENOMES FROM A MYSQL DATABASE
------------------------------------------------

The flat-file option above reads in all genomes into RAM. This may require too much memory, e.g. for a large number
of vertebrate-sized genomes. Also, this is inefficient when many parallel comparative AUGUSTUS runs are started on a
compute cluster. Therefore, another option allows to read only the required sequences from a MYSQL database:

a.) enabling mysql access:
    follow the instructions in docs/mysql.install.readme to install a mysql client and compile the mysql++ library
    
b.) creating a mysql database (example code) and a user:

> mysql -u root -p
> create database saeuger;
> select password('AVglssd8');
> create user `cgp`@`%` identified by password '*9D01B966C9648BD3B72A75CEB20A7BCCD41EDE5D'; /* or whatever the password code is*/
> grant all privileges on saeuger.* to cgp@'%';

c.) loading sequences into the database:
    Use the program 'load2db' in the AUGUSTUS repository.
    Run load2db with the parameter "--help" to view the usage instructions

> load2db --help
  
    Call 'load2db' for each genome, double check that the correct species identifier is used, e.g.

> load2db --species=hg19 --dbaccess=saeuger,localhost,cgp,AVglssd8 dir/to/genome/human.fa
> load2db --species=rheMac2 --dbaccess=saeuger,localhost,cgp,AVglssd8 dir/to/genome/rhesus.fa
> load2db --species=mm9 --dbaccess=saeuger,localhost,cgp,AVglssd8 dir/to/genome/mouse.fa
> load2db --species=bosTau4 --dbaccess=saeuger,localhost,cgp,AVglssd8 dir/to/genome/cow.fa
> load2db --species=galGal3 --dbaccess=saeuger,localhost,cgp,AVglssd8 dir/to/genome/chicken.fa    

d.) running AUGUSTUS with database access:

> augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --dbaccess=saeuger,localhost,cgp,AVglssd8


7. USING HINTS
---------------

Extrinsic evidence (or hints) can be integrated using a flat file or database access.
Note that you have to retrieve BOTH genomes and hints either from a flat file or
from the database. Mixed combinations are not possible.

Let's assume we have extrinsic evidence for human and mouse and already prepared the hints files for human and mouse in GFF format
(just as you would do it in the single species version of AUGUSTUS):

human.hints.gff contains hints from human RNA-seq and repeat masking

chr21   b2h     intron         	9908433	        9909046		0       .       .       pri=4;src=E
chr21   repmask nonexonpart     10018268        10018612        0       .       .       src=RM
chr21   w2h     ep      	48084612        48084621        41.600  .       .       src=W;pri=4;mult=41;


mouse.hints.gff contains hints from the mouse Refseq annotation

chr10   mm9_refGene     CDS     50409921        50410055        0.000000        +       0       source=M
chr10   mm9_refGene     intron  50410056        50419745        0.000000        +       .       source=M

a) retrieving hints from a flat file

   First concatenate the hints files into a single file. Prepend the species identifier to the sequence identifier (first column) in the hints files:

> cat human.hints.gff | perl -pe 's/(^chr\d+)/hg19\.$1/' >>hints.gff
> cat mouse.hints.gff | perl -pe 's/(^chr\d+)/mm9\.$1/' >>hints.gff

hints.gff now looks as follows

hg19.chr21   b2h     intron          9908433         9909046         0       .       .       pri=4;src=E
hg19.chr21   repmask nonexonpart     10018268        10018612        0       .       .       src=RM
hg19.chr21   w2h     ep              48084612        48084621        41.600  .       .       src=W;pri=4;mult=41;
mm9.chr10    mm9_refGene     CDS     50409921        50410055        0.000000        +       0       source=M
mm9.chr10    mm9_refGene     intron  50410056        50419745        0.000000        +       .       source=M

   prepare the extrinsic config file. Use config/extrinsic/cgp.extrinsic.cfg as template

   call AUGUSTUS (just as in the single species version) with the hints file and the extrinsic config file

> augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --speciesfilenames=genomes.tbl --hintsfile=hints.gff --extrinsicCfgFile=cgp.extrinsic.cfg

b) retrieving hints from database
   
   loading hints into the database works exactly the same as loading genomes into the database. Call 'load2db' to
   load hints for a particual species. Use the same species identifier as for the genomes:

> load2db --species=hg19 --dbaccess=saeuger,greifserv2,cgp,AVglssd8 human.hints.gff
> load2db --species=mm9 --dbaccess=saeuger,greifserv2,cgp,AVglssd8 mouse.hints.gff

   prepare the extrinsic config file. Use config/extrinsic/cgp.extrinsic.cfg as template

   call AUGUSTUS with --dbhints enabled:

> augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --dbaccess=saeuger,localhost,cgp,AVglssd8 --dbhints=true --extrinsicCfgFile=cgp.extrinsic.cfg


8. SQLITE ACCESS
------------------

Alternatively to Mysql, sequences and hints can also be accessed using an SQLite database
(in our experience the sqlite access runs more stabe than the mysql).
Other than the Mysql database that stores the full sequences, the SQLite database only stores
file offsets to achieve random access to the genome files.

a) Installation

   To enable access to an SQLITE database, install the package libsqlite3-dev with your package manager or 
   download the SQLite source code from http://www.sqlite.org/download.html/ 
   (tested with  SQLite 3.8.5 ) and install as follows:

   > tar zxvf sqlite-autoconf-3080500.tar.gz
   > cd sqlite-autoconf-3080500
   > ./configure
   > sudo make
   > sudo make install

   If you encounter an "SQLite header and source version mismatch" error, try

   > ./configure --disable-dynamic-extensions --enable-static --disable-shared

   Turn on the flag SQLITE in augustus/trunks/common.mk and recompile AUGUSTUS

b) create an SQLite database and populate it
   Use the program 'load2sqlitedb' in the AUGUSTUS repository.
   Run load2sqlitedb with the parameter "--help" to view the usage instructions

   > load2sqlitedb --help

   example code for loading a genome and a hints file to the database vertebrates.db
   (always load the genome file first, before loading hints):

   > load2sqlitedb --species=chicken --dbaccess=vertebrates.db genome.fa
   > load2sqlitedb --species=chicken --dbaccess=vertebrates.db hints.gff

c) running AUGUSUTS with SQLite db access:
   call AUGUSTUS with parameters --dbaccess AND --speciesfilenames

   > augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --dbaccess=vertebrates.db --speciesfilenames=genomes.tbl

   in order to retrieve hints from the database, enable --dbhints and pass an extrinsic config file

   > augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --dbaccess=vertebrates.db --speciesfilenames=genomes.tbl --dbhints=true --extrinsicCfgFile=cgp.extrinsic.cfg


9. TRAINING OF CLADE-SPECIFIC PARAMETERS (USUALLY NOT REQUIRED!!!)
------------------------------------------------------------------

Clade-specific parameters include the rates for exon gain and loss

--/CompPred/exon_loss=r
--/CompPred/exon_loss=r

as well as the scaling factor

--/CompPred/phylo_factor=f

If necessary, these parameters can be optimized similar to the meta parameters in single species gene prediction using the script 'optimize_augustus.pl'.
In short, a range of parameter values is specified for each parameter in a config file with the extension _metapars.cgp.cfg (e.g. human_metapars.cgp.cfg).
Different values in these ranges are tried out in several rounds and values giving highest accuracy are chosen.
In the evaluation step, the external program Eval¹ and a reference gene set are required.

a) Installation of Eval

   The software package eval by Keibler and Brent is required for retrieving accuracy values of predictions.
   It can be downloaded from

   > wget http://mblab.wustl.edu/media/software/eval-2.2.8.tar.gz
   > tar zxvf eval-2.2.8.tar.gz

   add following lines to your .bashrc file to include the perl executable evaluate_gtf.pl to your $PATH environment variable (optional),
   and the perl modules EVAL.pm and GTF.pm to your $PERL5LIB environment variable (mandatory)

   export PATH=$PATH:/path/to/eval-2.2.8
   export PERL5LIB=$PERL5LIB:/path/to/eval-2.2.8

   to check that the installation was successful, run following command

   >  evaluate_gtf.pl -v /path/to/eval-2.2.8/chr22.refseq.gtf /path/to/eval-2.2.8/chr22.twinscan.gtf /path/to/eval-2.2.8/chr22.genscan.gtf

b) Running optimize_augustus.pl for cgp parameter training
   Run optimize_augustus.pl and read the instructions in USAGE 2 for further information

   > optimize_augustus.pl

   exampe code: 

   > optimize_augustus.pl --species=human --treefile=tree.nwk --alnfile=aln.maf --dbaccess=db.vertebrates --speciesfilenames=genomes.tbl --eval_against=hg19 --stopCodonExcludedFromCDS=1 eval.gtf
   
   the file eval.gtf contains a reference gene set for the human genome that is used for evaluation

¹Keibler, E. and M.R. Brent. 2003. "Eval: A software package for analysis of genome annotations." BMC Bioinformatics 4:50.
   

10. BUILDING THE NEWICK PARSER FROM SCRATCH
    (not needed unless you run into compiler errors related to 'parse.cc' or 'lex.cc')
---------------------------------------------------------------------------------------

To parse phylogenetic trees in Newick format, AUGUSTUS-cgp uses a scanner and parser class, generated by Flexc++ and Bisonc++, respectively.
These classes are part of the AUGUSTUS package and can be used in most applications without the need for changing them.
However, if you have trouble compiling the Augustus source code and the compiler error is related to these classes (parse.cc' and 'lex.cc'), it is recommended to
rebuild the scanner and parser class from scratch.
The following will give you a step-by-step instruction, how to do this:

a) installation of Flexc++ and Bisonc++
b) creation of a scanner class with Flexc++
c) creation of a parser  class with Bisonc++
d) recompilation of AUGUSTUS-cgp

a) installation of Flexc++ and Bisonc++

- Flexc++ (lexical scanner generator, tested with V0.94.0) 

  download source code from http://flexcpp.sourceforge.net/ and follow the installation instructions. (Flexc++
  has several dependencies including the bobcat library. I recommend to use bobcat-3.10.00, if you do not want to install
  the latest g++ compiler)

-  Bisonc++ (parser generator, tested with V2.09.03)

   download source code from http://bisoncpp.sourceforge.net/ and follow the installation instructions or, alternatively,
   install bisonc++ via package manager:
   > sudo apt-get install bisonc++

b) creation of a scanner class with Flexc++:

   Switch to the directory src/scanner/ in your augustus folder and compile the file 'lexer' with Flexc++:

> flexc++ lexer
   
  The following files are generated: lex.cc scanner.h scanner.ih scannerbase.h
  Add the include directive '#include "../parser/parserbase.h"' to scanner.ih

> echo '#include "../parser/parserbase.h"' >>scanner.ih

c) creation of a parser class with Bisonc++

   Switch to the directory trunks/src/parser/ in your augustus folder and compile the file 'grammar' with Bisonc++

>  bisonc++ grammar

  The following files are generated: parse.cc parser.h  parser.ih  parserbase.h
  Edit the 'public' part of parser.h such that it looks as follows

class Parser: public ParserBase
{
    public:
        Parser(std::list<Treenode*> *tree, std::vector<std::string> *species, std::istream &in):d_scanner(in), ptree(tree), pspecies(species) {}
        Scanner d_scanner;
        std::list<Treenode*> *ptree;
        std::vector<std::string> *pspecies;

        int parse();

    private:
    ... // more code
};

d) recompilation of AUGUSTUS-cgp
   
   Switch to the directory 'trunks' in your augustus folder and type 

>  make clean all


11. TRAINING CGP SCORE PARAMETERS 
---------------------------------

To train the parameters used to score exon and intron candidates you have two options:

1)  if your training set (input alignment) is small, run AUGUSTUS as shown in the following example

 > augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --speciesfilenames=genomes.tbl --referenceFile=referenceFeature.gff --refSpecies=hg19 --param_outfile=params.cfg

This command will not predict genes. Specifying a reference file with --referenceFile will make augustus train feature parameters used to score exon and intron candidates using reference coding exons (CDS) and introns provided by the reference file. referenceFeature.gff needs to be in gtf, gff or gff3 format. All lines with type "intron" or "CDS" are used for training. Other lines will be ignored. Note, that the program is case sensitive. Stop codons need to be included in terminal coding exons. Specify the reference species with --refSpecies. The reference species must be one of the clade species and is denoted by the identifier used in the tree or alignment file. intron and CDS features in referenceFeature.gff must be from the reference species. 

The trained parameters are written to the file params.cfg. 

After training, run augustus in cgp mode with params.cfg as optional config file

 > augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --speciesfilenames=genomes.tbl --optCfgFile=params.cfg 

If --param_outfile is not specified parameters will be written to $AUGUSTUS_CONFIG_PATH/cgp/log_reg_parameters_trained.cfg. Of course the genomes can also be stored in mySQL or SQLite databases. Adjust the commands accordingly.


2) if option 1) takes to long you can parallelize the training by spliting the alignment file and run AUGUSTUS in parallel to collect all relevant attributes of all exon and intron candidates in the training set as follows

 > mkdir run1 run2 ...
 > for dir in run*; do
     > augustus --species=human --treefile=tree.nwk --alnfile=$dir/aln.maf --speciesfilenames=genomes.tbl --exoncands=1 --/CompPred/outdir=$dir --outfile=$dir/aug.out --errfile=$dir/aug.err &
 > done

concatenate the following files after all jobs are done 

 > cat run*/exonCands.refSpecies.gff3 run*/refSpecies.sampled_GFs.gff run*/orthoExons.refSpecies.gff3 > all_exon_intron_candidates.gff

run AUGUSTUS again, now in training mode using all_exon_intron_candidates.gff (this is fast)

 > augustus --species=human --treefile=tree.nwk --referenceFile=referenceFeature.gff --refSpecies=hg19 --trainFeatureFile=all_exon_intron_candidates.gff --param_outfile=params.cfg

The trained parameters are written to the file params.cfg.

After training, run augustus in cgp mode with params.cfg as optional config file

 > augustus --species=human --treefile=tree.nwk --alnfile=aln.maf --speciesfilenames=genomes.tbl --optCfgFile=params.cfg

If --param_outfile is not specified parameters will be written to $AUGUSTUS_CONFIG_PATH/cgp/log_reg_parameters_trained.cfg. Of course the genomes can also be stored in mySQL or SQLite databases. Adjust the commands accordingly.

