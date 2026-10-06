#!/bin/bash
#SBATCH -J cactus_vcf_gzip
#SBATCH -o vcf_gzip_%j.out
#SBATCH -e vcf_gzip_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --mail-type=END,FAIL

set -euo pipefail

# ============================================================
# Compress and index VCF files
#
# Input:
#   Stacks/populations_all_snps/populations.snps.vcf
#   Stacks/populations_random_snp/populations.snps.vcf
#
# Output:
#   Corresponding .vcf.gz and .vcf.gz.tbi files
#
# The project directory is detected automatically from the
# location of this script.
# ============================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VCF1="${PROJECT_DIR}/Stacks/populations_all_snps/populations.snps.vcf"
VCF2="${PROJECT_DIR}/Stacks/populations_random_snp/populations.snps.vcf"

module purge
module load bioinfo/Bcftools/1.9

echo "Compressing and indexing VCF files"
echo "--------------------------------------------------"

for VCF in "${VCF1}" "${VCF2}"
do
    echo "Processing: ${VCF}"

    if [[ ! -f "${VCF}" ]]; then
        echo "ERROR: VCF not found: ${VCF}"
        exit 1
    fi

    # Compress with bgzip
    bgzip -f "${VCF}"

    # Index with tabix
    tabix -p vcf "${VCF}.gz"

    echo "Created:"
    ls -lh "${VCF}.gz" "${VCF}.gz.tbi"

    echo "Number of SNPs:"
    bcftools view -H "${VCF}.gz" | wc -l

    echo "Number of samples:"
    bcftools query -l "${VCF}.gz" | wc -l

    echo "--------------------------------------------------"
done

echo "Finished compressing and indexing VCF files."
