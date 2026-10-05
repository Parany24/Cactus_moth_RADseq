#!/bin/bash
#SBATCH -J cactus_missing
#SBATCH -o /home/gdobigny/work/Cactus_moth_RADseq/Stacks/missing_data/missing_data_%j.out
#SBATCH -e /home/gdobigny/work/Cactus_moth_RADseq/Stacks/missing_data/missing_data_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --mail-user=paranymamionah@gmail.com
#SBATCH --mail-type=END,FAIL

set -euo pipefail

PROJECT_DIR="/home/gdobigny/work/Cactus_moth_RADseq"
OUT_DIR="${PROJECT_DIR}/Stacks/missing_data"

mkdir -p "${OUT_DIR}"

module purge
module load bioinfo/VCFtools/0.1.16

VCF_ALL="${PROJECT_DIR}/Stacks/populations_all_snps/populations.snps.sorted.vcf.gz"
VCF_RANDOM="${PROJECT_DIR}/Stacks/populations_random_snp/populations.snps.sorted.vcf.gz"

echo "Estimating missing data with VCFtools"
echo "Output directory: ${OUT_DIR}"
echo "--------------------------------------------------"

for DATASET in all_snps random_snp
do
    if [[ "${DATASET}" == "all_snps" ]]; then
        VCF="${VCF_ALL}"
    else
        VCF="${VCF_RANDOM}"
    fi

    echo "Dataset: ${DATASET}"
    echo "VCF: ${VCF}"

    if [[ ! -f "${VCF}" ]]; then
        echo "ERROR: VCF not found: ${VCF}"
        exit 1
    fi

    # Missingness per individual
    vcftools \
        --gzvcf "${VCF}" \
        --missing-indv \
        --out "${OUT_DIR}/${DATASET}"

    # Missingness per site/SNP
    vcftools \
        --gzvcf "${VCF}" \
        --missing-site \
        --out "${OUT_DIR}/${DATASET}"

    echo "Finished missingness for ${DATASET}"
    echo "Created:"
    ls -lh "${OUT_DIR}/${DATASET}.imiss" "${OUT_DIR}/${DATASET}.lmiss"
    echo "--------------------------------------------------"
done

echo "Missing data estimation finished."

