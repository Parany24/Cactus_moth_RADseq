#!/bin/bash
#SBATCH -J cactus_fastqc
#SBATCH -o fastqc_%j.out
#SBATCH -e fastqc_%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=24:00:00


# ============================================================
# FastQC quality control for cactus moth RADseq FASTQ files
# Input:  /home/gdobigny/work/Cactus_moth_RADseq/Raw_data
# Output: /home/gdobigny/work/Cactus_moth_RADseq/QC/fastqc_reports
# ============================================================

# Define directories
raw_data_dir="/home/gdobigny/work/Cactus_moth_RADseq/Raw_data"
output_dir="/home/gdobigny/work/Cactus_moth_RADseq/QC/fastqc_reports"

# Create output directory outside Raw_data
mkdir -p "${output_dir}"

# Load FastQC
module purge
module load bioinfo/FastQC/0.12.1

# Move to raw data directory
cd "${raw_data_dir}"

# Loop through all R1 files
for r1_file in *_1.fastq.gz
do
    # Derive sample name by removing _1.fastq.gz
    sample=$(basename "${r1_file}" _1.fastq.gz)

    # Define corresponding R2 file
    r2_file="${sample}_2.fastq.gz"

    # Check that R2 exists
    if [[ -f "${r2_file}" ]]
    then
        echo "Processing sample: ${sample}"
        echo "R1: ${r1_file}"
        echo "R2: ${r2_file}"

        # Run FastQC on both paired-end files
        fastqc \
            --threads 4 \
            "${r1_file}" "${r2_file}" \
            --outdir "${output_dir}"
    else
        echo "WARNING: R2 file not found for ${sample}, skipping ${r1_file}"
    fi
done

echo "FastQC analysis complete."
echo "Reports saved in: ${output_dir}"

