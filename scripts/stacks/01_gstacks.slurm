#!/bin/bash
#SBATCH -J cactus_gstacks
#SBATCH -o /home/gdobigny/work/Cactus_moth_RADseq/Stacks/gstacks/gstacks_%j.out
#SBATCH -e /home/gdobigny/work/Cactus_moth_RADseq/Stacks/gstacks/gstacks_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=80G
#SBATCH --time=72:00:00
#SBATCH --mail-user=paranymamionah@gmail.com
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

PROJECT_DIR="/home/gdobigny/work/Cactus_moth_RADseq"

BAM_DIR="${PROJECT_DIR}/Stacks/bam_biological_names"
POPMAP="${PROJECT_DIR}/Stacks/popmap_biological_names.tsv"
GSTACKS_OUT="${PROJECT_DIR}/Stacks/gstacks"

mkdir -p "${GSTACKS_OUT}"

module purge
module load bioinfo/Stacks/2.68

echo "Running gstacks"
echo "BAM directory: ${BAM_DIR}"
echo "BAM suffix: .sorted.bam"
echo "Popmap: ${POPMAP}"
echo "Output directory: ${GSTACKS_OUT}"

gstacks \
    -I "${BAM_DIR}" \
    -S .sorted.bam \
    -M "${POPMAP}" \
    -O "${GSTACKS_OUT}" \
    -t 16 \
    --min-mapq 10

echo "gstacks finished successfully."

