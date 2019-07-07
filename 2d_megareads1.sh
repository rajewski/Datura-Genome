#This scrip is simply the output line from history/2c_HybAssemble-5473295.out modified to have higher memory and email me

sbatch -D /rhome/arajewski/bigdata/Datura/mr_pass1 \
    -J create_mega_reads \
    -a 1-12 \
    -n 32 \
    -p highmem \
    --mem 512gb \
    -N 1 \
    --mail-user=araje002@ucr.edu \
    --mail-type=ALL \
    --out /rhome/arajewski/bigdata/Datura/history/2d_megareads1-%A.out \
    mr_pass1/create_mega_reads.sh
