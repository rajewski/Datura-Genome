#!/bin/bash -l

# Directory with files to upload. All files here will be uploaded
INDIR=/bigdata/littlab/arajewski/Datura/NCBI_Submission/Dstr_MTmask_tmp/genome.sqn
# Temp directory to create on NCBI's servers
NCBIDIR=Dstr_Annotation_210909


module load aspera
ascp \
	-i /opt/linux/centos/7.x/x86_64/pkgs/aspera/3.6.0/etc/asperaweb_id_dsa.openssh \
	-QT \
	-k1 \
	-d \
	$INDIR \
	subasp@upload.ncbi.nlm.nih.gov:uploads/rajewski23_gmail.com_gZm1ZLeM/${NCBIDIR}
