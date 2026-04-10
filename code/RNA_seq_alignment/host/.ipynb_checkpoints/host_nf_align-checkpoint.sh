#!/bin/bash
#SBATCH --mem=300G
#SBATCH -p scavenger
#SBATCH -c 20
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
-name MGT450_host_align \
-profile singularity \
-work-dir /cwork/mt354/MGT450_HCV_TRIBE_rerun/MGT450_host_align/work \
-params-file /cwork/mt354/MGT450_HCV_TRIBE_rerun/MGT450_host_align/host_nf-params.json