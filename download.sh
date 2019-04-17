#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=8G
#SBATCH --time=10:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p batch

#curl http://www.medplantrnaseq.org/assemblies/Datura_stramonium.tar.gz > Datura_stramonium1.tar.gz
curl http://www.medplantrnaseq.org/assemblies/Datura_stramonium.tar.gz > Datura_stramonium2.tar.gz
curl http://www.medplantrnaseq.org/assemblies/datura_stramonium-20100406/README > README1.txt
curl http://www.medplantrnaseq.org/assemblies/datura_stramonium-20101112/README > README2.txt
