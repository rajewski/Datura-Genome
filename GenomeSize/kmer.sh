#!/bin/bash -l
#SBATCH --ntasks=14
#SBATCH --nodes=1
#SBATCH --mem=100G
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p batch
#SBATCH -o ../history/slurm-%A.out
set -euv
FQ=chi2_r1_sum100k.fq

module load jellyfish/2.2.9
jellyfish count -m 9 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_9mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_9mer_out.histo Test_sub1m_9mer_counts.jf
rm Test_sub1m_9mer_counts.jf

jellyfish count -m 10 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_10mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_10mer_out.histo Test_sub1m_10mer_counts.jf
rm Test_sub1m_10mer_counts.jf

jellyfish count -m 11 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_11mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_11mer_out.histo Test_sub1m_11mer_counts.jf
rm Test_sub1m_11mer_counts.jf

jellyfish count -m 12 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_12mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_12mer_out.histo Test_sub1m_12mer_counts.jf
rm Test_sub1m_12mer_counts.jf

jellyfish count -m 13 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_13mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_13mer_out.histo Test_sub1m_13mer_counts.jf
rm Test_sub1m_13mer_counts.jf

jellyfish count -m 14 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_14mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_14mer_out.histo Test_sub1m_14mer_counts.jf
rm Test_sub1m_14mer_counts.jf

jellyfish count -m 15 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_15mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_15mer_out.histo Test_sub1m_15mer_counts.jf
rm Test_sub1m_15mer_counts.jf

jellyfish count -m 20 -s 2014M --min-qual-char=6 -t $SLURM_NTASKS -C  -o Test_sub1m_20mer_counts.jf $FQ
jellyfish histo -t $SLURM_NTASKS -o Test_sub1m_20mer_out.histo Test_sub1m_20mer_counts.jf
rm Test_sub1m_20mer_counts.jf
