#This script is simply the output line from history/2c_HybAssemble-908396.out modified to have higher memory and email me
#sbatch -D /rhome/arajewski/bigdata/Datura/2_MaSuRCA338/mr_pass1 -J create_mega_reads -a 1-12 -n 60 -p batch -N 1 mr_pass1/create_mega_reads.sh

sbatch -D /rhome/arajewski/bigdata/Datura/2_MaSuRCA338/mr_pass1 \
    -J create_mega_reads \
    -a 12 \
    --ntasks 32  \
    --mem 450gb \
    -p batch \
    -N 1 \
    --time=2-00:00:00 \
    --mail-user=araje002@ucr.edu \
    --mail-type=ALL \
    --out /rhome/arajewski/bigdata/Datura/history/2d_megareads_%A-%a.out \
    mr_pass1/create_mega_reads.sh
