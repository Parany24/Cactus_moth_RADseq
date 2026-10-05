#!/bin/bash
#SBATCH -J cactus_cov
#SBATCH -o /home/gdobigny/work/Cactus_moth_RADseq/Coverage/logs/coverage_%A_%a.out
#SBATCH -e /home/gdobigny/work/Cactus_moth_RADseq/Coverage/logs/coverage_%A_%a.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=paranymamionah@gmail.com

set -euo pipefail

PROJECT_DIR="/home/gdobigny/work/Cactus_moth_RADseq"
BAM_DIR="${PROJECT_DIR}/Mapping/bam"
SAMPLE_LIST="${PROJECT_DIR}/samples_bam.txt"
REF_FAI="${PROJECT_DIR}/genome_reference_cactorum/Ccactorum.fcs_gx_2026_FINAL.fa.fai"
OUT_DIR="${PROJECT_DIR}/Coverage/per_sample"

mkdir -p "${OUT_DIR}"

module purge
module load bioinfo/samtools/1.20

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SAMPLE_LIST}")

BAM="${BAM_DIR}/${SAMPLE}.sorted.bam"
OUT="${OUT_DIR}/${SAMPLE}.coverage.tsv"

if [[ ! -f "${BAM}" ]]; then
    echo "ERROR: BAM file not found: ${BAM}"
    exit 1
fi

if [[ ! -f "${BAM}.bai" ]]; then
    echo "ERROR: BAM index not found: ${BAM}.bai"
    exit 1
fi

if [[ ! -f "${REF_FAI}" ]]; then
    echo "ERROR: reference .fai not found: ${REF_FAI}"
    exit 1
fi

GENOME_SIZE=$(awk '{sum += $2} END {print sum}' "${REF_FAI}")

echo "Sample: ${SAMPLE}"
echo "BAM: ${BAM}"
echo "Genome size: ${GENOME_SIZE}"

echo -e "SRA\tgenome_size_bp\ttotal_depth_sum\tgenome_wide_mean_depth\tcovered_bases\tbreadth_covered_percent\tmean_depth_covered_sites" > "${OUT}"

samtools depth -aa "${BAM}" \
    | awk -v sample="${SAMPLE}" -v genome_size="${GENOME_SIZE}" 'BEGIN{OFS="\t"}
        {
            depth_sum += $3
            if ($3 > 0) {
                covered_bases += 1
                covered_depth_sum += $3
            }
        }
        END{
            genome_wide_mean_depth = depth_sum / genome_size
            breadth_covered_percent = (covered_bases / genome_size) * 100

            if (covered_bases > 0) {
                mean_depth_covered_sites = covered_depth_sum / covered_bases
            } else {
                mean_depth_covered_sites = 0
            }

            print sample, genome_size, depth_sum, genome_wide_mean_depth, covered_bases, breadth_covered_percent, mean_depth_covered_sites
        }' >> "${OUT}"

echo "Coverage finished for ${SAMPLE}"

