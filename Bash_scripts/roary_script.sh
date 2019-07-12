#!/bin/bash
#SBATCH --ntasks 100
#SBATCH --time 40:0:0
#SBATCH --node 50
#SBATCH --qos castles
#SBATCH --mail-type ALL

module purge; module load bluebear
module load Roary/3.12.0

roary -n -e -z  *.gff