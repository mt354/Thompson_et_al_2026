#!/bin/bash
#SBATCH --mem=128G
#SBATCH -p scavenger
#SBATCH -c 4
#SBATCH -e logs/quant-%A_%a.err
#SBATCH -o logs/quant-%A_%a.out

# Path to conda environment with bullseye installed
env=/hpc/group/hornerlab/mt354/miniconda3/envs/Bullseye

# Path to downloaded Bullseye scripts
SOFTWARE=/hpc/group/hornerlab/mt354/Bullseye_updated/Code/quant

# Path to the required input files
bedfile=/cwork/mt354/MGT279_TRIBE_SEQ/bullseye/HCV/edit_sites/summary_beds/IFIT3_ADAR_all.bed
matrix=/cwork/mt354/MGT279_TRIBE_SEQ/bullseye/HCV/matrix_files

module load Anaconda3/2024.02
source activate $env

# List all bed files in array, zero-indexed
matrixfiles=(${matrix}/{ctl*,ifit3*}gz)

# Pick the matrix file for this task
matrix=${matrixfiles[$SLURM_ARRAY_TASK_ID]}
prefix=$(basename "${matrix%%.*}")

perl $SOFTWARE/quantify_sites.pl \
    --bed "$bedfile" \
    --EditedMatrix "${matrix}" \
    --outfile "edit_sites/quant_results/${prefix}.ifit3.out" \
    --editType A2I \
    --minEdit 1 \
    --maxEdit 100 \
    --EditedMinCoverage 10 \
    --cpu 4 \
    --verbose