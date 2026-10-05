#!/bin/bash
#SBATCH -J cactus_multiqc
#SBATCH -o multiqc_%j.out
#SBATCH -e multiqc_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00

# ============================================================
# MultiQC summary report for cactus moth RADseq FastQC results
# Input:  /home/gdobigny/work/Cactus_moth_RADseq/QC/fastqc_reports
# Output: /home/gdobigny/work/Cactus_moth_RADseq/QC/multiqc_reports
# ============================================================

# Define directories
reports_dir="/home/gdobigny/work/Cactus_moth_RADseq/QC/fastqc_reports"
output_dir="/home/gdobigny/work/Cactus_moth_RADseq/QC/multiqc_reports"

# Create output directory outside Raw_data
mkdir -p "${output_dir}"

# Load MultiQC
module purge
module load bioinfo/MultiQC/1.35

# Run MultiQC
multiqc "${reports_dir}" \
    --outdir "${output_dir}" \
    --filename cactus_moth_multiqc_report.html

echo "MultiQC analysis complete."
echo "Report saved in: ${output_dir}/cactus_moth_multiqc_report.html"
