#!/bin/bash

set -euo pipefail

PROJECT_DIR="/work/user/gdobigny/Cactus_moth_RADseq"
MAPPING_TABLE="${PROJECT_DIR}/mapping_table.tsv"

# Your real BAMs are named with SRA accessions
ORIGINAL_BAM_DIR="${PROJECT_DIR}/Mapping/bam"

# This new folder will contain symbolic links named with biological sample names
STACKS_BAM_DIR="${PROJECT_DIR}/Stacks/bam_biological_names"

# Stacks popmap must use the same sample names as the BAM links
POPMAP="${PROJECT_DIR}/Stacks/popmap_biological_names.tsv"

mkdir -p "${STACKS_BAM_DIR}"
mkdir -p "${PROJECT_DIR}/Stacks"

# Clean previous links and previous popmap
rm -f "${STACKS_BAM_DIR}"/*.bam
rm -f "${STACKS_BAM_DIR}"/*.bai
> "${POPMAP}"

echo "Preparing Stacks inputs"
echo "--------------------------------------------------"
echo "Mapping table:        ${MAPPING_TABLE}"
echo "Original BAM folder:  ${ORIGINAL_BAM_DIR}"
echo "Stacks BAM folder:    ${STACKS_BAM_DIR}"
echo "Popmap:              ${POPMAP}"
echo "--------------------------------------------------"

# Check mapping table
if [[ ! -f "${MAPPING_TABLE}" ]]; then
    echo "ERROR: mapping_table.tsv not found:"
    echo "${MAPPING_TABLE}"
    exit 1
fi

# Check duplicated biological sample names
DUP_SAMPLES=$(tail -n +2 "${MAPPING_TABLE}" | cut -f2 | sort | uniq -d)

if [[ -n "${DUP_SAMPLES}" ]]; then
    echo "ERROR: duplicated biological Sample names found:"
    echo "${DUP_SAMPLES}"
    exit 1
fi

# Check duplicated SRA names
DUP_SRA=$(tail -n +2 "${MAPPING_TABLE}" | cut -f1 | sort | uniq -d)

if [[ -n "${DUP_SRA}" ]]; then
    echo "ERROR: duplicated SRA names found:"
    echo "${DUP_SRA}"
    exit 1
fi

# Create report of missing BAMs
MISSING_REPORT="${PROJECT_DIR}/Stacks/missing_bams_for_stacks.tsv"
echo -e "SRA\tSample\tPop\tMissing_file" > "${MISSING_REPORT}"

# Create symlinks and popmap
tail -n +2 "${MAPPING_TABLE}" | while IFS=$'\t' read -r SRA Sample Pop Locality Province Latitude Longitude Host Total_reads Mapped_reads Mapped_percent Properly_paired Properly_paired_percent
do
    ORIGINAL_BAM="${ORIGINAL_BAM_DIR}/${SRA}.sorted.bam"
    ORIGINAL_BAI="${ORIGINAL_BAM_DIR}/${SRA}.sorted.bam.bai"

    NEW_BAM="${STACKS_BAM_DIR}/${Sample}.sorted.bam"
    NEW_BAI="${STACKS_BAM_DIR}/${Sample}.sorted.bam.bai"

    if [[ ! -f "${ORIGINAL_BAM}" ]]; then
        echo "WARNING: missing BAM for ${SRA} / ${Sample}"
        echo -e "${SRA}\t${Sample}\t${Pop}\t${ORIGINAL_BAM}" >> "${MISSING_REPORT}"
        continue
    fi

    if [[ ! -f "${ORIGINAL_BAI}" ]]; then
        echo "WARNING: missing BAM index for ${SRA} / ${Sample}"
        echo -e "${SRA}\t${Sample}\t${Pop}\t${ORIGINAL_BAI}" >> "${MISSING_REPORT}"
        continue
    fi

    # Link SRA-named BAM to biological-sample-named BAM
    ln -sf "${ORIGINAL_BAM}" "${NEW_BAM}"
    ln -sf "${ORIGINAL_BAI}" "${NEW_BAI}"

    # Popmap must match the BAM basename expected by Stacks:
    # BAMF373E.sorted.bam with suffix .sorted.bam means sample name = BAMF373E
    echo -e "${Sample}\t${Pop}" >> "${POPMAP}"

done

echo "--------------------------------------------------"
echo "Finished."

echo "Number of biological-name BAM links:"
find "${STACKS_BAM_DIR}" -name "*.sorted.bam" | wc -l

echo "Number of biological-name BAM index links:"
find "${STACKS_BAM_DIR}" -name "*.sorted.bam.bai" | wc -l

echo "Number of samples in popmap:"
wc -l "${POPMAP}"

echo "First lines of popmap:"
head "${POPMAP}"

echo "First biological-name BAM links:"
find "${STACKS_BAM_DIR}" -name "*.sorted.bam" | head

echo "Missing BAM report:"
cat "${MISSING_REPORT}"

