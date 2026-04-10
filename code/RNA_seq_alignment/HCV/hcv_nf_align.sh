#!/bin/bash
#SBATCH --mem=100G
#SBATCH -p scavenger
#SBATCH -c 10
#SBATCH -J nf_align
#SBATCH --mail-user=mt354@duke.edu
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output=output_%j.txt
#SBATCH --error=error_%j.txt

# load anaconda and activate nextflow environment
module load Anaconda3/2021.05

source activate /hpc/group/hornerlab/mt354/miniconda3/envs/nextflow_env

nextflow run nf-core/rnaseq \
-r 3.14.0 \
-resume \
-c /cwork/mt354/MGT450_HCV_TRIBE_rerun/MGT450_hcv_align/nextflow.config \
-name MGT450_hcv_align_v2 \
-profile singularity \
-work-dir /cwork/mt354/MGT450_HCV_TRIBE_rerun/MGT450_hcv_align/work \
-params-file /cwork/mt354/MGT450_HCV_TRIBE_rerun/MGT450_hcv_align/hcv_nf-params.json