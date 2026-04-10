#!/bin/bash
#SBATCH --mem=16G
#SBATCH -p scavenger
#SBATCH -c 4
#SBATCH -e logs/slurm-findedit-%A_%a.err
#SBATCH -o logs/slurm-findedit-%A_%a.out


# perl Find_edit_site.pl
#--annotationFile	: mm10 FlatRef Annotation file (s)
#--controlMatrix	: control count matrix (wtRNA or mutYTH) (s)
#--EditedMatrix		: DART RNA count matrix (s)
#--genome		: instead of using a control file, DART dataset will be compared to sequence in fasta file. Provide path to folder containing multiple fasta or to a single fasta file (s)
#--fallback		: Optional Path to genome file (fasta). If provided, will be used to compare mutation to in the case where control matrix has no/low coverage (s)
#
#--editType		: Conversion to quantify in the following format : C2U (default) or A2I (s)
#
#--minEdit		: (NEW) minimal editing percentage for sites to be considered default to 10%. please write as a number without % symbol (f)
#--maxEdit		: (NEW) maximum editing percentage for sites to be considered default to 80%. please write as a number without % symbol (f)
#--editFoldThreshold	: Threshold edited/control mutation rate, defaults to 1: by defaults no filtering is done. number can be increased for filtering here, or data can be filtered later. (f)
#--MinEditSites		: minimum number of edit sites, defaults to 2 (i)
#--ControlMinCoverage	: (NEW) minimum coverage for in control file for sites to be considered: if using genome and score option, this number will be used for computation. defaults to 10 (i)
#--EditedMinCoverage	: (NEW) minimum coverage for in control file for sites to be considered: defaults to 10 (i)
#--outfile		: Output bed file, defaults to STDOUT (s)
#--bed6			: output an extra bed6 file, if -o is used, usual file will be generates as .bed, and and extra BED6 will be used with .bed6
#--verbose		: display extra log information
#--scratch		: scratch directory used to temp files: defaults to ./SCRATCH (s)
#--inton		: site detection will be done in both exons and introns
#--extUTR		: Extend 3'UTR region by 5kb for site detection
#--score		: score and filter reads based on probability of edit based on beta distribution curve. Sites with 10 fold higher probability in DART/control will be kept (f)
#--KnownSites   : use this for bed files in a refflat is not available

#
#Run as sbatch -a 1-n find_RNA_edit_sites.sh dart.file control.file.1 control.file.2 control.file.3 ...
#


###### Variables to be set ##################################################################

# Path to conda environment with bullseye installed
bull_env=/hpc/group/hornerlab/mt354/miniconda3/envs/Bullseye

# Path to downloaded Bullseye scripts
SOFTWARE=/hpc/group/hornerlab/mt354/Bullseye_updated/Code

# Enter path to write outputs
dest=/cwork/mt354/MGT279_TRIBE_SEQ/bullseye/host/edit_sites/beds

# Path to refFlat annotation file
annotation_file=/hpc/group/hornerlab/mt354/genomes/GRCh38.refflat

# Path annotation genome fasta (if not comparing to other control matrix)
GENOME=/hpc/group/hornerlab/mt354/genomes/NCBI/GRCh38_no_alt_analysis_set.fna

# Type of editing. C2U, A2U, G2A, etc
edit=A2I

#############################################################################################

###### Switch between genome or control matrix depending on analyses #####
#Pick 1 of these options and add to the perl code below
#       --genome $GENOME \
# 	    --controlMatrix $control.matrix.gz \
##########################################################################

#activate conda environment for Bullseye
module load Anaconda3/2024.02
source activate $bull_env

file=$1
dart=$(basename $file .matrix.gz)
files=($@)
comp=${files[SLURM_ARRAY_TASK_ID]}
control=$(basename $comp .matrix.gz)
out=$dart.$control.01.$edit.bed

if [[ $# == 0 ]]
then 
	echo "Please input at least 2 files for comparison"
	exit 
else
    echo
	perl $SOFTWARE/Find_edit_site.pl \
        --annotationFile $annotation_file \
        --EditedMatrix $file \
        --controlMatrix $comp \
    	--editType $edit \
    	--minEdit 1 \
    	--maxEdit 100 \
    	--editFoldThreshold 0 \
    	--EditedMinCoverage 10 \
    	--ControlMinCoverage 10 \
    	--MinEditSites 2 \
    	--outfile $out \
    	--verbose
fi

mv $out $dest
