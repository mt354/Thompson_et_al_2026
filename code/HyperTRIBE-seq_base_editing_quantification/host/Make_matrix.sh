#!/bin/bash
#SBATCH --mem=128G
#SBATCH -c 8
#SBATCH -a 1-9
#SBATCH -p common
#SBATCH -e logs/slurm-matrix-%A_%a.err
#SBATCH -o logs/slurm-matrix-%A_%a.out

# adjust number of arrays to correspond to number of bam files to process
# depending on the size of your bam files, you may need to adjust the amount of RAM used

###### Directories to be set#################################################################

# Path to conda environment with bullseye installed
bull_env=/hpc/group/hornerlab/mt354/miniconda3/envs/Bullseye

# Path to downloaded Bullseye scripts
SOFTWARE=/hpc/group/hornerlab/mt354/Bullseye_updated/Code

# Enter path to write outputs
dest=/cwork/mt354/MGT279_TRIBE_SEQ/bullseye/host

# Enter a name for the new matrix file directory
dest_name=/matrix_files_1

# Enter path to .bam,.bai files
bams=/cwork/mt354/MGT279_TRIBE_SEQ/alignments/GRCh38/star_salmon

#############################################################################################

#make directories to store bullseye files
mkdir -p $dest$dest_name

cd $bams
file=$(ls *.bam | sed -n ${SLURM_ARRAY_TASK_ID}p)   ### can change ls to subset the analysis to some bam files (.sorted.bam)
STEM=$(basename "$file" .bam)


####### list of options for parseBAM.pl #######
# This program will build a matrix of nucleotide count for every positions mapped in a bam file:
	# --mode : one of 'Bulk', 'SingleCell' or 'ExtractBarcodes'. Default to Bulk. 
	# --input: input bam file used to build matrix. Make sure files are coordinated sorted
	# --output: output file name, defaults to STDOUT
	# --removeDuplicates: To ignore reads marked as PCR or optical duplicates
    # --removeMultiMapped: To ignore multi mapped reads 
	# --verbose: display extra information
	# --cpu: number of threads to use for processing (only necessary if you are not using slurm)
	# --mem: available memory for sorting (M) (only necessary if you are not using slurm)
	# --minCoverage: minimum base coverage to output to final file (default = 1)
	# --filterBarcodes: only keep the barcodes included in the first column of a provided file. 
	# 			A second column with the number of reads for each barcode can be provided and used for filtering with the following options:
	# --MaxBarcodes: (sc) number of barcodes to process (defaults to all). Will stop reading provided barcode file after hitting this number, barcodes should be filered by mapped reads.
	# --readThreshold: (sc) minimum number of reads for barcodes to be considered
	# --Cell_ID_pattern: pattern for to use for single cell processing. use 10X, SMART or enter a sam tag RegEx for cell identification.
    # --exclude: bed file with coordinates for regions to be skipped. (eg. Ribosomal RNAs.) 
#######			end of options			#######
	
#activate conda environment for Bullseye
module load Anaconda3/2024.02
source activate $bull_env

echo 'processing' $file

echo 'Started at' `date +"%D %H:%M"`

perl $SOFTWARE/parseBAM.pl --input $file --output $STEM.matrix --verbose --minCoverage 10

mv $STEM.matrix* $dest$dest_name

echo 'Ended at' `date +"%D %H:%M"`

