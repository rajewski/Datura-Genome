#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/wgd-%A.out

# Get Env Right
PATH=/rhome/arajewski/.local/bin:$PATH
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
module load mcl/14-137
module load ncbi-blast/2.2.30+
module load diamond/0.9.24
module load paml/4.9
module load mafft/7.471
module load fasttree/2.1.11

DsDir=../5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/annotate_results/
DsCDS=Datura_stramonium.cds-transcripts.fa
DsPro=Datura_stramonium.proteins.fa
SlDir=ExternalData/Slyc/
SlCDS=ITAG4.0_CDS.fasta
SlPro=ITAG4.0_proteins.fasta
NaDir=ExternalData/Natt_NADH/
NaCDS=NIATT_r2.0.cds
NaPro=NIATT_r2.0.aa
VvDir=ExternalData/Vvin/
VvCDS=Vvinifera_457_v2.1.cds_primaryTranscriptOnly.fa
VvPro=Vvinifera_457_v2.1.protein_primaryTranscriptOnly.fa

# ##### Diamond Search #####
# # paralogs
# wgd dmd \
#     --nostrictcds \
#     --ignorestop \
#     $DsDir/$DsCDS
# wgd dmd \
#     --nostrictcds \
#     --ignorestop \
#     $VvDir/$VvCDS
# wgd dmd \
#     --nostrictcds \
#     --ignorestop \
#     $SlDir/$SlCDS
# wgd dmd \
#     --nostrictcds \
#     --ignorestop \
#     $NaDir/$NaCDS
# # orthologs
# wgd dmd \
#     --nostrictcds \
#     --ignorestop \
#     $DsDir/$DsCDS $VvDir/$VvCDS $SlDir/$SlCDS
# wgd dmd \
#   --nostrictcds \
#   --ignorestop \
#   $SlDir/$SlCDS $NaDir/$NaCDS
# 
# ##### ks distros #####
# # paralogs
# wgd ksd \
#     -n $SLURM_CPUS_PER_TASK \
#     -p $DsDir/$DsPro \
#     wgd_dmd/$DsCDS.mcl $DsDir/$DsCDS
# wgd ksd \
#     -n $SLURM_CPUS_PER_TASK \
#     -p $VvDir/$VvPro \
#     wgd_dmd/$VvCDS.mcl $VvDir/$VvCDS
# wgd ksd \
#     -n $SLURM_CPUS_PER_TASK \
#     -p $SlDir/$SlPro \
#     wgd_dmd/$SlCDS.mcl $SlDir/$SlCDS
wgd ksd \
    -n $SLURM_CPUS_PER_TASK \
    -p $NaDir/$NaPro \
    wgd_dmd/$NaCDS.mcl $NaDir/$NaCDS
# # pairwise orthologs
# cat $SlDir/$SlPro $DsDir/$DsPro > ExternalData/Sl_Ds_proteins.fasta
# cat $SlDir/$SlPro $VvDir/$VvPro > ExternalData/Sl_Vv_proteins.fasta
# cat $VvDir/$VvPro $DsDir/$DsPro > ExternalData/Vv_Ds_proteins.fasta
cat $SlDir/$SlPro $NaDir/$NaPro > ExternalData/Sl_Na_proteins.fasta

# wgd ksd \
#   -n $SLURM_CPUS_PER_TASK \
#   -p ExternalData/Sl_Ds_proteins.fasta \
#   wgd_dmd/Datura_stramonium.cds-transcripts.fa_ITAG4.0_CDS.fasta.rbh \
#   $DsDir/$DsCDS $SlDir/$SlCDS
# wgd ksd \
#   -n $SLURM_CPUS_PER_TASK \
#   -p ExternalData/Sl_Vv_proteins.fasta \
#   wgd_dmd/ITAG4.0_CDS.fasta_Vvinifera_457_v2.1.cds_primaryTranscriptOnly.fa.rbh \
#   $VvDir/$VvCDS $SlDir/$SlCDS
# wgd ksd \
#   -n $SLURM_CPUS_PER_TASK \
#   -p ExternalData/Vv_Ds_proteins.fasta \
#   wgd_dmd/Datura_stramonium.cds-transcripts.fa_Vvinifera_457_v2.1.cds_primaryTranscriptOnly.fa.rbh \
#   $DsDir/$DsCDS $VvDir/$VvCDS
wgd ksd \
  -n $SLURM_CPUS_PER_TASK \
  -p ExternalData/Sl_Na_proteins.fasta \
  wgd_dmd/${SlCDS}_${NaCDS}.rbh \
  $SlDir/$SlCDS $NaDir/$NaCDS

##### Mixture Models #####
# They are only supported for single-species analyses
# wgd mix \
#   -r 0.005 2 \
#   -o wgd_mix_Dstr \
#   --method bgmm \
#   wgd_ksd/$DsPro.ks.tsv
# wgd mix \
#   -r 0.005 2 \
#   -o wgd_mix_Vvin \
#   --method bgmm \
#   wgd_ksd/$VvPro.ks.tsv
# wgd mix \
#   -r 0.005 2 \
#   -o wgd_mix_Slyc \
#   --method bgmm \
#   wgd_ksd/$SlPro.ks.tsv
wgd mix \
  -r 0.005 2 \
  -o wgd_mix_Natt \
  --method bgmm \
  wgd_ksd/$NaPro.ks.tsv
wgd mix \
  -r 0.005 2 \
  -o wgd_mix_Sl_v_Na \
  --method bgmm \
  wgd_ksd/Sl_Na_proteins.fasta.ks.tsv

##### Visualize #####
#Use the MakeFigure.R script
