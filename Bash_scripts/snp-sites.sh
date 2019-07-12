#!/bin/bash
#SBATCH --ntasks 50
#SBATCH --time 1:0:0
#SBATCH --qos castles
#SBATCH --mail-type ALL

module purge; module load bluebear
module load bear-apps/2018b
module load snp-sites/2.4.1-foss-2018b

snp-sites -m -o core_snp.fa core_gene_alignment.aln