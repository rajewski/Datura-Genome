# Datura-Genome

The goal of this project is to examine the impacts of genetic transformation (speccifically involving tissue culture) on the genome structure and gene expression patterns in *Datura stramonium*. This repository contains the scripts I have used to create a draft reference genome of the plant, annotate that genome for both genes and putative transposable elements, and finally to compare gene expression and potential transposon bursts with this draft and resequencing data from 3 transgenic progeny of the reference genome plant.

## Data Availability

The raw Illumina sequencing reads (DNA and RNA libraries) have been deposited at NCBI along with the low-coverage Oxford Nanopore data.

__Add in the accession numbers here__

## Overview

### `GenomeSize/`
I used SmudgePlot and GenomeScope to estimate the genome size, ploidy, and heterozygosity from the short read data prior to assembly. This was also repeated on the libraries of the genome resequenced plants as well

### `2_ABySS`
Having confirmed that I was working with a diploid, fairly inbred, human-sized genome I tested several assemblers that seemed appropriate before settling on ABySS. I swept across several possible k-mer sizes for the assembly and picked an optimum based on contiguity and the percent of BUSCO genes in this preliminary assembly.

### `3_BCGSC`
Because I have only low-coverage long-read data, I chose to first create a short-read only assembly with ABySS and then to scaffold, gap fill, and polish the genome using both the short-read and long-read data. I chose several tools from Canada's Michael Smith Genome Sciences Centre. I iteratively scaffolded the ABySS assembly with LINKS using error-corrected Nanopore data. After each round of LINKS scaffolding, I applied ntEdit to polish the genome until the number of edits stabilized. Then I gap filled the newly created scaffolds with RAILS and Cobbler, and polished several more times with ntEdit. This process was then repeated using LINKS with a larger gap size, up to a maximum of 100kb.

After this iterative scaffolding and gap filling step, I used Sealer to polish the genome with short-read data. I allowed Sealer to attempt to fill gaps up to 2kb, but most filled gaps were <500bp.

### `4_BUSCO`
To assess the completeness of the genome, I ran a BUSCO analysis to find the expected universal single-copy orthologs. At this stage I also length filtered the assembly to remove the large number of small contigs. They would be excluded from an NCBI upload based on size and also drastically increase the time needed to functionally annotate the genome without contributing to the BUSCO score.

### `4_RepeatModeler`
Prior to gene annotation, I softmasked repetitive elements from the genome. Previous attempts showed that failure to mask these repeats caused the prediciton software to drastically overinflate the number of possible genes. I created a custom repeat library using RepeatModeler and used this to softmask the assembly.

### `4_EDTA`
To create a more comprehensive inventory of transposable elements (TEs), I used the EDTA pipeline to find LTR, TIR, and Helitron transpoable elements. This inventory of TEs will later be used to compare differences between the reference genome and the resequenced, transformed progeny.

### `5_Funannotate`
To generate a genic annotation of the assembly, I used the Funannotate pipeline, which combines several tools for both *ab initio* and evidence-based gene prediction. Although originally developed for fungal genome annotation, the pipeline scales well to larger eukaryotic genomes and is very thorough in it analysis.

### `6_RelocaTE2`
Using the TE annotation created by EDTA, I then used RelocaTE2 to examine the TE polymorphisms between the reference and transgenic individuals.

### `6_DEGs`
With the genic annotation of the assembly produced by Funannotate, I then used DESeq two (in R) to conduct a quick differential gene expression analysis from leaf tissue of the genome resequened, transformed plants compared to siblings of the reference genome plant. I also focused this analysis on genes that showed evidence of proximal TE movement based on the RelocaTE2 analysis

