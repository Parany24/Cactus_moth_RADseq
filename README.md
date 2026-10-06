# Cactus moth RADseq

Bioinformatics workflow for RADseq data analysis of the cactus moth  
*Cactoblastis cactorum*.

## Workflow

```text
01_quality_control/
        ↓
02_read_processing/
        ↓
03_mapping/
        ↓
04_variant_calling/
        ↓
05_population_structure/
        ↓
06_results/
```

## Repository structure

```text
Cactus_moth_RADseq/
├── 01_quality_control/
├── 02_read_processing/
├── 03_mapping/
├── 04_variant_calling/
├── 05_population_structure/
├── 06_results/
├── metadata/
├── .gitignore
├── LICENSE
└── README.md
```

## Main tools

- FastQC / MultiQC
- Stacks
- BWA / SAMtools
- VCFtools / BCFtools
- ADMIXTURE
- R / Python
- SLURM

## Data

Large sequencing and genomic files are not stored in this repository.

The following directories remain on the HPC server and are excluded from Git:

```text
Raw_data/
Clean_data/
QC/
Mapping/
Stacks/
Coverage/
genome_reference_cactorum/
```

## Reproducibility

The repository contains the scripts, metadata and selected results used to document the analysis workflow.

Scripts use paths relative to the project directory whenever possible.
