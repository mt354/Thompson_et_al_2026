#!/bin/bash
#SBATCH --job-name=permute_chunk_bash
#SBATCH -p scavenger
#SBATCH --output=logs/permute_%A_%a.out
#SBATCH --error=logs/permute_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --array=1-2

# =========================
# Print usage
usage() {
    echo "Usage: $0 -n N_PERMUT_TOTAL -c CHUNK_SIZE -i TRIBE_BED -j CONTROL_BED -g GENOME_SIZES -w WHITELIST_BED -r COMP_DIR -p PERMUT_DIR"
    echo "  -n  Total permutations"
    echo "  -c  Chunk size"
    echo "  -i  TRIBE BED file"
    echo "  -j  CONTROL BED file"
    echo "  -g  Genome sizes file"
    echo "  -w  Whitelist BED file"
    echo "  -r  Directory of beds to be compared against"
    echo "  -p  Output directory for permutations"
}

# =========================
# Parse arguments
while getopts n:c:i:j:g:w:r:p: flag; do
    case "${flag}" in
        n) N_PERMUT_TOTAL=${OPTARG};;
        c) CHUNK_SIZE=${OPTARG};;
        i) TRIBE_BED=${OPTARG};;
        j) CONTROL_BED=${OPTARG};;
        g) GENOME_SIZES=${OPTARG};;
        w) WHITELIST_BED=${OPTARG};;
        r) COMP_DIR=${OPTARG};;
        p) PERMUT_DIR=${OPTARG};;
        *) usage; exit 1 ;;
    esac
done

# =========================
# Check if all required args are present
if [ -z "$N_PERMUT_TOTAL" ] || [ -z "$CHUNK_SIZE" ] || [ -z "$TRIBE_BED" ] || [ -z "$CONTROL_BED" ] || [ -z "$GENOME_SIZES" ] || [ -z "$WHITELIST_BED" ] || [ -z "$COMP_DIR" ] || [ -z "$PERMUT_DIR" ]; then
    echo "Error: missing required argument."
    usage
    exit 1
fi

mkdir -p "$PERMUT_DIR"
mkdir -p logs/
module load Anaconda3/2024.02
source activate /hpc/group/hornerlab/mt354/miniconda3/envs/jupyter_python_env/

START=$(( (SLURM_ARRAY_TASK_ID - 1) * CHUNK_SIZE + 1 ))
END=$(( SLURM_ARRAY_TASK_ID * CHUNK_SIZE ))
if (( END > N_PERMUT_TOTAL )); then
  END=$N_PERMUT_TOTAL
fi
echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"
echo "Processing permutations from $START to $END"
echo "TRIBE_BED=$TRIBE_BED"
echo "CONTROL_BED=$CONTROL_BED"
echo "GENOME_SIZES=$GENOME_SIZES"
echo "WHITELIST_BED=$WHITELIST_BED"
echo "COMP_DIR=$COMP_DIR"
echo "PERMUT_DIR=$PERMUT_DIR"

shuffle_once() {
  input_bed=$1
  output_bed=$2
  bedtools shuffle -i "$input_bed" -g "$GENOME_SIZES" -incl "$WHITELIST_BED" -noOverlapping > "$output_bed"
}

for (( i=START; i<=END; i++ )); do
  TRIBE_SHUF="$PERMUT_DIR/TRIBE_SHUF.${i}.bed"
  CONTROL_SHUF="$PERMUT_DIR/CONTROL_SHUF.${i}.bed"
  if [[ ! -f "$TRIBE_SHUF" ]]; then
    shuffle_once "$TRIBE_BED" "$TRIBE_SHUF"
  fi
  if [[ ! -f "$CONTROL_SHUF" ]]; then
    shuffle_once "$CONTROL_BED" "$CONTROL_SHUF"
  fi
  echo "Generated shuffle $i"
done

for rbp_bed in "$COMP_DIR"/*.bed; do
  rbp_name=$(basename "$rbp_bed" .bed)
  out_file="$PERMUT_DIR/permdiff_chunk_${START}_${END}_${rbp_name}.txt"
  > "$out_file"
  echo "Processing $rbp_name (perms $START-$END)"
  for (( i=START; i<=END; i++ )); do
    tribe_cnt=$(bedtools intersect -u -s -a "$PERMUT_DIR/TRIBE_SHUF.${i}.bed" -b "$rbp_bed" | wc -l)
    ctrl_cnt=$(bedtools intersect -u -s -a "$PERMUT_DIR/CONTROL_SHUF.${i}.bed" -b "$rbp_bed" | wc -l)
    diff=$(( tribe_cnt - ctrl_cnt ))
    echo "$diff" >> "$out_file"
  done
done