# Thompson et al. 2026
This repository contains scripts and instructions for reproducing the analyses performed in Thompson et al. 2026.

---

## Usage divided by method
---

### RNA-seq alignment

- `code/RNA_seq_alignment` contains a jupyter notebook describing the software and scripts used to align host and viral RNA seq reads
  - Host and HCV subfolders contain individual scripts called as well as relevant configuration files
- Host reference genome is described in the notebook. The HCV reference files derived from GenBank: AB047639.1 can be found in `/HCV_genome`


### HyperTRIBE-seq RNA editing quantification

- `code/HyperTRIBE-seq_base_editing_quantification` contains a jupyter notebook describing the software and scripts used to align host and viral RNA seq reads
  - `host` and `HCV` subfolders contain individual scripts called as well as relevant configuration files
- `combined` subfolder contains .Rmd and functions used for GLM analyses of editing sites between conditions
- All Bullseye related code used was cloned from https://github.com/mflamand/Bullseye/tree/main

### Overlap permutation analyses of HyperTRIBE-seq with published CLIP-seq data

- `code/Overlap_permutation_analyses` contains a jupyter notebook, companion scripts `overlap_scripts.py`, and job submission scripts.
- The notebook first describes the preprocessing steps taken to filter published data and prep HyperTRIBE edit data for overlap analyses.
- Then an example analyses of the overlaps between IFIT3-ADAR and ADAR-YTH (as in 2D) is shown. This workflow was used for all permutation analyses described in the manuscript.

## Contact

For questions, contact mt354@duke.edu CC stacy.horner@duke.edu.
