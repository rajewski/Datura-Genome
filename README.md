# Datura-Genome

This is a collection of scripts and also very much a work-in-progress currently. My overall goals are to:

1. Estimate the genome size and heterozygosity witha kmer based approach
2. Assemble a draft genome with my Illumina data
3. Begin to annotate the gene space, potentially including TEs, ncRNA, etc
4. If possible, use long-read data to generate a more complete genome. I am aware that, should this happen, I will likely want to assemble with the long reads first and then polish with my illumina data.

Currently the GenomeSize/ directy is beginning to address the genome size and heterozygosity problem I have mentioned. I have tried this with low-coverage seuqencing, but I do not a reliable estimate, or at least not a consistent one, though at certain kmers, I can get an estimate that agrees with Kew Gardens 2Gb estimates based on flow cytometry.

To address aim two, I plan to begin with Velvet and eventually try out other assemblers if Velvet takes too much time/memory or produces a cruddy assembly. My backup assemblers are SOAP and Planatus so far, but I am open to other possibilities.
