#!/bin/bash
#SBATCH --mem=64G
#SBATCH -p scavenger
#SBATCH -c 4
#SBATCH -e logs/slurm-summarize-%A_%a.err
#SBATCH -o logs/slurm-summarize-%A_%a.out

# =============== Default Paths ================
bull_env=/hpc/group/hornerlab/mt354/miniconda3/envs/Bullseye
SOFTWARE=/hpc/group/hornerlab/mt354/Bullseye_updated/Code
BEDS=""

# =============== Default summarize_sites.pl Parameters ================
MINREP=3
FOLD=0
COVERAGE=10
MUT=0
EDIT=0
REPONLY=false

# =============== Usage ================
usage() {
    echo
    echo "Usage: $0 -s \"stem1 stem2\" -d /dest/path [other options]"
    echo "Required:"
    echo "  -s \"stem1 stem2 ...\"      List of sample name stems (quoted, space-separated)"
    echo "  -d /dest/path             Output directory"
    echo "Optional:"
    echo "  -r MINREP                 --minRep (minimum number of replicates) [default: $MINREP]"
    echo "  -f FOLD                   --fold (min fold over control to keep sites) [default: $FOLD]"
    echo "  -c COVERAGE               --coverage (min coverage to keep site) [default: $COVERAGE]"
    echo "  -u MUT                    --mut (min # mutations per rep) [default: $MUT]"
    echo "  -e EDIT                   --edit (min editing rate) [default: $EDIT]"
    echo "  -R                        --repOnly"
    echo "  -b /beds/path             BED files directory [default: $BEDS]"
    echo "  -h                        Show this help."
    echo
    exit 1
}

# =============== Parse Flags ================
while getopts "s:d:r:f:c:u:e:Rhb:" opt; do
    case $opt in
        s) STEMS=($OPTARG) ;;
        d) dest=$OPTARG ;;
        r) MINREP=$OPTARG ;;
        f) FOLD=$OPTARG ;;
        c) COVERAGE=$OPTARG ;;
        u) MUT=$OPTARG ;;
        e) EDIT=$OPTARG ;;
        R) REPONLY=true ;;
        b) BEDS=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

mkdir -p $dest

# Check required arguments
if [[ -z "$dest" ]] || [[ "${#STEMS[@]}" -eq 0 ]]; then
    usage
fi

# =============== Environment ================
module load Anaconda3/2024.02
source activate "$bull_env"

# =============== Run ================
for STEM in "${STEMS[@]}"; do
    FILES=( "$BEDS"/"$STEM"* )
    echo "Summarizing files for $STEM:"
    for file in "${FILES[@]}"; do
        echo "  $file"
    done

    # Build command
    cmd=(perl "$SOFTWARE"/summarize_sites.pl
        --minRep "$MINREP"
        --fold "$FOLD"
        --coverage "$COVERAGE"
        --mut "$MUT"
        --edit "$EDIT"
    )

    if $REPONLY; then
        cmd+=(--repOnly)
    fi

    cmd+=("${FILES[@]}")

    cd "$dest"

    # Run summarize_sites.pl and move output
    "${cmd[@]}" > "$STEM".00.bed

done