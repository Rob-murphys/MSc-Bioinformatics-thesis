#!/bin/bash
#SBATCH --ntasks 50
#SBATCH --time 5:0:0
#SBATCH --qos castles
#SBATCH --mail-type ALL

module purge; 
module load bluebear;
module load bear-apps/2018b;
module load FastTree/2.1.10-foss-2018b

alingment_file=core_snp_23+CladeIRM.fa
output_tree=core_snp_23+CladeIRM_MLTree.nwk
FastTree -gtr -nt $alingment_file > $output_tree