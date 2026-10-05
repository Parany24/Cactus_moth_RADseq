#!/bin/bash
#SBATCH -J cactus_miss_filter
#SBATCH -o /home/gdobigny/work/Cactus_moth_RADseq/Stacks/missing_filter_tests/missing_filter_%j.out
#SBATCH -e /home/gdobigny/work/Cactus_moth_RADseq/Stacks/missing_filter_tests/missing_filter_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --mail-user=paranymamionah@gmail.com
#SBATCH --mail-type=END,FAIL

set -euo pipefail

# ============================================================
# Test several SNP-level missingness thresholds for both VCFs
#
# Datasets:
#   1. all SNPs per RAD locus
#   2. one random SNP per RAD locus
#
# For each dataset and threshold:
#   - filter with vcftools --max-missing
#   - sort, compress and index the filtered VCF
#   - estimate per-individual missingness
#   - summarize SNP number and individual missingness
#
# Output:
#   /home/gdobigny/work/Cactus_moth_RADseq/Stacks/missing_filter_tests
# ============================================================

PROJECT_DIR="/home/gdobigny/work/Cactus_moth_RADseq"
OUT_DIR="${PROJECT_DIR}/Stacks/missing_filter_tests"

mkdir -p "${OUT_DIR}"

module purge
module load bioinfo/VCFtools/0.1.16
module load bioinfo/Bcftools/1.9

# Input VCFs
VCF_ALL="${PROJECT_DIR}/Stacks/populations_all_snps/populations.snps.vcf.gz"
VCF_RANDOM="${PROJECT_DIR}/Stacks/populations_random_snp/populations.snps.vcf.gz"

# Summary output
SUMMARY="${OUT_DIR}/missing_filter_summary_both_datasets.tsv"

echo -e "Dataset\tMax_missing_threshold\tN_samples\tN_SNPs\tMean_ind_missing\tMedian_ind_missing\tMin_ind_missing\tMax_ind_missing\tN_ind_gt20_missing\tN_ind_gt30_missing\tN_ind_gt50_missing" > "${SUMMARY}"

echo "Testing missingness thresholds"
echo "Output directory: ${OUT_DIR}"
echo "Summary table: ${SUMMARY}"
echo "--------------------------------------------------"

# Thresholds to test
THRESHOLDS="0.50 0.60 0.70 0.80 0.90"

# Loop over datasets
for DATASET in all_snps random_snp
do

    if [[ "${DATASET}" == "all_snps" ]]; then
        VCF="${VCF_ALL}"
    else
        VCF="${VCF_RANDOM}"
    fi

    echo "Dataset: ${DATASET}"
    echo "Input VCF: ${VCF}"

    if [[ ! -f "${VCF}" ]]; then
        echo "ERROR: VCF not found: ${VCF}"
        exit 1
    fi

    # Loop over missingness thresholds
    for MISS in ${THRESHOLDS}
    do

        echo "--------------------------------------------------"
        echo "Dataset: ${DATASET}"
        echo "Applying --max-missing ${MISS}"

        PREFIX="${OUT_DIR}/${DATASET}_maxmissing_${MISS}"

        # ----------------------------------------------------
        # Filter sites by global missingness
        # ----------------------------------------------------

        vcftools \
            --gzvcf "${VCF}" \
            --max-missing "${MISS}" \
            --recode \
            --recode-INFO-all \
            --out "${PREFIX}"

        # ----------------------------------------------------
        # Sort, compress and index filtered VCF
        # ----------------------------------------------------

        echo "Sorting filtered VCF..."

        bcftools sort \
            -Oz \
            -o "${PREFIX}.sorted.vcf.gz" \
            "${PREFIX}.recode.vcf"

        echo "Indexing sorted VCF..."

        tabix -p vcf "${PREFIX}.sorted.vcf.gz"

        FILTERED_VCF="${PREFIX}.sorted.vcf.gz"

        # Remove temporary uncompressed VCF
        rm -f "${PREFIX}.recode.vcf"

        # ----------------------------------------------------
        # Count SNPs and samples
        # ----------------------------------------------------

        N_SNP=$(bcftools view -H "${FILTERED_VCF}" | wc -l)

        N_SAMPLES=$(bcftools query -l "${FILTERED_VCF}" | wc -l)

        echo "Filtered VCF: ${FILTERED_VCF}"
        echo "Number of SNPs: ${N_SNP}"
        echo "Number of samples: ${N_SAMPLES}"

        # ----------------------------------------------------
        # Estimate per-individual missingness
        # ----------------------------------------------------

        vcftools \
            --gzvcf "${FILTERED_VCF}" \
            --missing-indv \
            --out "${PREFIX}"

        # ----------------------------------------------------
        # Summarize individual missingness
        # ----------------------------------------------------

        awk \
            -v dataset="${DATASET}" \
            -v miss="${MISS}" \
            -v nsamples="${N_SAMPLES}" \
            -v nsnp="${N_SNP}" '

        NR > 1 {

            f[NR-1] = $5

            sum += $5

            if (NR == 2 || $5 < min)
                min = $5

            if (NR == 2 || $5 > max)
                max = $5

            if ($5 > 0.20)
                gt20++

            if ($5 > 0.30)
                gt30++

            if ($5 > 0.50)
                gt50++
        }

        END {

            n = NR - 1

            if (n == 0) {

                mean = "NA"
                median = "NA"
                min = "NA"
                max = "NA"

            } else {

                asort(f)

                mean = sum / n

                if (n % 2 == 1) {

                    median = f[(n + 1) / 2]

                } else {

                    median = (f[n / 2] + f[n / 2 + 1]) / 2
                }
            }

            print dataset "\t" \
                  miss "\t" \
                  nsamples "\t" \
                  nsnp "\t" \
                  mean "\t" \
                  median "\t" \
                  min "\t" \
                  max "\t" \
                  gt20+0 "\t" \
                  gt30+0 "\t" \
                  gt50+0

        }' "${PREFIX}.imiss" >> "${SUMMARY}"

        echo "Finished ${DATASET} with --max-missing ${MISS}"

    done

done

echo "--------------------------------------------------"
echo "All missingness threshold tests finished."
echo
echo "Summary:"
cat "${SUMMARY}"
