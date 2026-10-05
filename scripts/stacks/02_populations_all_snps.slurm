#!/bin/bash
#SBATCH -J cactus_pop_allsnps
#SBATCH -o /home/gdobigny/work/Cactus_moth_RADseq/Stacks/populations_all_snps/populations_all_snps_%j.out
#SBATCH -e /home/gdobigny/work/Cactus_moth_RADseq/Stacks/populations_all_snps/populations_all_snps_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=80G
#SBATCH --time=48:00:00
#SBATCH --mail-user=paranymamionah@gmail.com
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

PROJECT_DIR="/home/gdobigny/work/Cactus_moth_RADseq"

GSTACKS_DIR="${PROJECT_DIR}/Stacks/gstacks"
POPMAP="${PROJECT_DIR}/Stacks/popmap_biological_names.tsv"
POP_OUT="${PROJECT_DIR}/Stacks/populations_all_snps"

mkdir -p "${POP_OUT}"

module purge
module load bioinfo/Stacks/2.68

echo "Running populations: all SNPs per locus"
echo "Input gstacks directory: ${GSTACKS_DIR}"
echo "Popmap: ${POPMAP}"
echo "Output directory: ${POP_OUT}"

populations \
-P "${GSTACKS_DIR}" \
-M "${POPMAP}" \
-O "${POP_OUT}" \
-t 16 \
-p 2 \
-r 0.80 \
--min-maf 0.05 \
--max-obs-het 0.70 \
--vcf \
--structure \
--plink \
--genepop \
--fstats

echo "populations all-SNPs run finished successfully."
echo "Output files:"
ls -lh "${POP_OUT}"
