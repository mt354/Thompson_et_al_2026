#!/bin/bash
#SBATCH --mem=128G
#SBATCH -p scavenger
#SBATCH -c 4
#SBATCH -e logs/gather-%A_%a.err
#SBATCH -o logs/gather-%A_%a.out

# Path to conda environment with bullseye installed
env=/hpc/group/hornerlab/mt354/miniconda3/envs/Bullseye

# Path to downloaded Bullseye scripts
SOFTWARE=/hpc/group/hornerlab/mt354/Bullseye_updated/Code/quant

beds=/cwork/mt354/MGT279_TRIBE_SEQ/bullseye/host/edit_sites/quant_results/*ifit3.bed

module load Anaconda3/2024.02
source activate $env

# Here, we select all generated quant_results/*.bed files for merging.
perl $SOFTWARE/gather_sites.pl \
    --score \
    --coverage \
    --mutations \
    --outfile edit_sites/final_results/ifit3_adar_gathered.out \
    $beds