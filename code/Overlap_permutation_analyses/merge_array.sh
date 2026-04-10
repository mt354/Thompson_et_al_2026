#!/bin/bash
#SBATCH --job-name=merge_array
#SBATCH -p scavenger
#SBATCH -e logs/merge_array-%A_%a.err
#SBATCH -o logs/merge_array-%A_%a.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=0:20:00

# Usage
usage() {
    echo "Usage: $0 -p PERMUT_DIR -m MERGE_OUT_DIR -l RBP_NAMES_LIST"
    exit 1
}

#### Example of generating the RBP names list ####

# ls "$PERMUT_DIR"/permdiff_chunk_*_*.txt | sed -E 's/.*permdiff_chunk_[0-9]+_[0-9]+_(.*)\.txt/\1/' | sort | uniq > rbp_names.txt

#### Example submission line ####

# sbatch --array=1-$(wc -l < rbp_names.txt) merge_array.sh -p "$PERMUT_DIR" -m "$MERGE_OUT_DIR" -l rbp_names.txt

# This creates an array for each RBP

while getopts p:m:l: flag; do
    case ${flag} in
        p) PERMUT_DIR=${OPTARG};;
        m) MERGE_OUT_DIR=${OPTARG};;
        l) RBP_NAMES_LIST=${OPTARG};;
        *) usage;;
    esac
done

if [ -z "$PERMUT_DIR" ] || [ -z "$MERGE_OUT_DIR" ] || [ -z "$RBP_NAMES_LIST" ] || [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    usage
fi

mkdir -p "$MERGE_OUT_DIR"

# Get RBP name for this task
RBP_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$RBP_NAMES_LIST")

# Merge all chunk files for this RBP
cat "$PERMUT_DIR"/permdiff_chunk_*_"$RBP_NAME".txt > "$MERGE_OUT_DIR/${RBP_NAME}_permdiff.txt"