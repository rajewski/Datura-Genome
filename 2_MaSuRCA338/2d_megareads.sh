#This script is simply the output line from history/2c_HybAssemble-1104890.out modified to have higher memory and email me

sbatch \
    -D /rhome/arajewski/bigdata/Datura/2_MaSuRCA338/mr_pass1 \
    -J create_mega_reads \
    --array=1-12 \
    --ntasks=30 \
    --mem-per-cpu=16G \
    -p batch,intel,highmem \
    -N 1 \
    --mail-user=araje002@ucr.edu \
    --mail-type=ALL \
    --out /rhome/arajewski/bigdata/Datura/history/2d_megareads_%A-%a.out \
    mr_pass1/create_mega_reads.sh
