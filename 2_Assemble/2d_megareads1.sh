#This scrip is simply the output line from history/2c_HybAssemble-5473295.out modified to have higher memory and email me

sbatch -D /rhome/arajewski/bigdata/Datura/2_Assemble/mr_pass1 \
    -J create_mega_reads \
    -a 12,11,10 \
    --ntasks 32 \
    -p intel,batch \
    --mem 450gb \
    -N 1 \
    --time=1-19:00:00 \
    --mail-user=araje002@ucr.edu \
    --mail-type=ALL \
    --out /rhome/arajewski/bigdata/Datura/history/2d_megareads1_%A-%a.out \
    mr_pass1/create_mega_reads.sh
