# Cactus moth RADseq

Bioinformatics workflow for RADseq data analysis of the cactus moth *Cactoblastis cactorum*.

## Project overview

This repository contains scripts, metadata, summary tables and selected figures generated during the analysis of RADseq data from *Cactoblastis cactorum*.

The main objectives are to process RADseq data, perform sequence quality control and mapping, generate SNP datasets, and investigate population genetic structure and ancestry.

## Analysis workflow

The analysis is organized into several main steps:

1. **Quality control**
   - Quality assessment of sequencing data
   - FastQC and MultiQC reports

2. **Read processing and demultiplexing**
   - RADseq read processing
   - Adapter removal and demultiplexing using Stacks

3. **Read mapping**
   - Mapping of cleaned reads to the *Cactoblastis cactorum* reference genome
   - Mapping statistics and coverage estimation

4. **SNP discovery and filtering**
   - SNP calling using Stacks
   - Filtering of SNP datasets
   - Assessment of missing data
   - Generation of filtered VCF datasets

5. **Population structure**
   - ADMIXTURE analyses
   - Estimation of ancestry proportions
   - Population assignment
   - Geographic and host-associated patterns of genetic structure

6. **Results**
   - Summary tables
   - Population assignments
   - Ancestry estimates
   - Figures used for downstream analyses and manuscript preparation

## Repository structure

```text
Cactus_moth_RADseq/
├── 00_reference/
├── 01_QC/
├── 02_mapping/
├── 03_Stacks/
├── 04_population_structure/
├── 05_results/
│
├── scripts/
│   ├── coverage/
│   ├── mapping/
│   ├── mapping_summary/
│   ├── process_radtags/
│   └── stacks/
│
├── Clean_data/
├── Coverage/
├── Mapping/
├── Raw_data/
├── Stacks/
├── genome_reference_cactorum/
│
├── .gitignore
└── README.md
