#This script is simply the output line from history/2c_HybAssemble-258030.out modified to have higher memory and email me

sbatch -D /rhome/arajewski/bigdata/Datura/2_MaSuRCA333/mr_pass1 \
    -J create_mega_reads \
    -a 1-12 \
    --ntasks 32 \
    -p highmem \
    --mem 450gb \
    -N 1 \
    --time=3-00:00:00 \
    --mail-user=araje002@ucr.edu \
    --mail-type=ALL \
    --out /rhome/arajewski/bigdata/Datura/history/2d_megareads1_%A-%a.out \
    mr_pass1/create_mega_reads.sh
