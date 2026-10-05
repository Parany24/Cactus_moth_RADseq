#!/bin/bash
#SBATCH -J cactus_vcf_gzip
#SBATCH -o /home/gdobigny/work/Cactus_moth_RADseq/Stacks/vcf_gzip_%j.out
#SBATCH -e /home/gdobigny/work/Cactus_moth_RADseq/Stacks/vcf_gzip_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --mail-user=paranymamionah@gmail.com
#SBATCH --mail-type=END,FAIL

set -euo pipefail

module purge
module load bioinfo/Bcftools/1.9

VCF1="/home/gdobigny/work/Cactus_moth_RADseq/Stacks/populations_all_snps/populations.snps.vcf"
VCF2="/home/gdobigny/work/Cactus_moth_RADseq/Stacks/populations_random_snp/populations.snps.vcf"

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

