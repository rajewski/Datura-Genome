.DELETE_ON_ERROR:

#program locations
KMCC=/opt/linux/centos/7.x/x86_64/pkgs/KMC/3.1.1/bin/kmc
KMCD=/opt/linux/centos/7.x/x86_64/pkgs/KMC/3.1.1/bin/kmc_dump
FSG=/rhome/arajewski/bigdata/Datura/software/fastsg/FastSG++

Dstr_v1.3_k101.kmc.K${K}.txt:
	${KMCC} -r -k${K} -v -m4 -fm -ci1 -cx1 -t16 /rhome/arajewski/bigdata/Datura/2_ABySS/k_101/Dstr_v1.3_k101-scaffolds.fa.2kb.fa Dstr_v1.3_k101.kmc.K${K} Dstr_v1.3_k101.kmctmp.K${K} 2>Dstr_v1.3_k101.kmc.K${K}.err >Dstr_v1.3_k101.kmc.K${K}.log
	${KMCD} Dstr_v1.3_k101.kmc.K${K} Dstr_v1.3_k101.kmc.K${K}.txt
Dstr_v1.3_k101.fast-sg.K${K}.done: Dstr_v1.3_k101.kmc.K${K}.txt
	${FSG} $^ /rhome/arajewski/bigdata/Datura/2_ABySS/k_101/Dstr_v1.3_k101-scaffolds.fa.2kb.fa ${K} 16 ultra-long-conf.txt 9 5 3 19 15 3 200 2>$@.err 
	touch Dstr_v1.3_k101.fast-sg.K${K}.done

all: Dstr_v1.3_k101.kmc.K${K}.txt Dstr_v1.3_k101.fast-sg.K${K}.done 

clean:
	rm -f Dstr_v1.3_k101.kmc.K${K}.txt Dstr_v1.3_k101.fast-sg.K${K}.done
