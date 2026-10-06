#!/bin/bash SBATCH -J cactus_radtags SBATCH -o 
#process_radtags_adapters_%j.out SBATCH -e 
#process_radtags_adapters_%j.err SBATCH --partition=workq SBATCH 
#--ntasks=1 SBATCH --cpus-per-task=4 SBATCH --mem=12G SBATCH 
#--time=48:00:00
set -euo pipefail
# ============================================================ Stacks 
# process_radtags for cactus moth RADseq data
#
# Input: Raw_data/
#
# Output: Clean_data/process_radtags_adapters/
#
# The project directory is detected automatically from the location of 
# this script. 
# ============================================================ Define 
# project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Define input and output directories
RAW_DIR="${PROJECT_DIR}/Raw_data" 
CLEAN_DIR="${PROJECT_DIR}/Clean_data/process_radtags_adapters"
# Create output directory
mkdir -p "${CLEAN_DIR}"
# Load Stacks
module purge module load bioinfo/Stacks/2.68
# Process RADseq reads
process_radtags \ -P \ -p "${RAW_DIR}" \ -o "${CLEAN_DIR}" \ --renz-1 
    nspI \ --renz-2 dpnII \ -c \ -q \ -r \ --adapter-1 
    AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \ --adapter-2 
    AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \ --adapter-mm 2 \ --threads 4
echo "process_radtags finished successfully."
echo "Cleaned files are in: ${CLEAN_DIR}"
