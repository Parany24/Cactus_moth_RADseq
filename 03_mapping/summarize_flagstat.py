import os
import re
import csv
from glob import glob

# ============================================================
# Summarize SAMtools flagstat mapping statistics
#
# Input:
#   Mapping/stats/*.flagstat.txt
#
# Output:
#   Mapping/summary/mapping_summary.csv
#
# The project directory is detected automatically from the
# location of this script.
# ============================================================

PROJECT_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..")
)

stats_dir = os.path.join(
    PROJECT_DIR,
    "Mapping",
    "stats"
)

summary_dir = os.path.join(
    PROJECT_DIR,
    "Mapping",
    "summary"
)

outfile = os.path.join(
    summary_dir,
    "mapping_summary.csv"
)

os.makedirs(summary_dir, exist_ok=True)

files = sorted(
    glob(os.path.join(stats_dir, "*.flagstat.txt"))
)

with open(outfile, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)

    writer.writerow([
        "Sample",
        "Total_reads",
        "Mapped_reads",
        "Mapped_percent",
        "Properly_paired",
        "Properly_paired_percent"
    ])

    for f in files:

        sample = os.path.basename(f).replace(
            ".flagstat.txt",
            ""
        )

        total = ""
        mapped = ""
        mapped_pct = ""
        paired = ""
        paired_pct = ""

        with open(f) as infile:

            for line in infile:

                if "in total" in line:
                    total = line.split()[0]

                elif " mapped (" in line and "primary" not in line:
                    mapped = line.split()[0]

                    match = re.search(
                        r"\(([\d\.]+)%",
                        line
                    )

                    if match:
                        mapped_pct = match.group(1)

                elif "properly paired" in line:
                    paired = line.split()[0]

                    match = re.search(
                        r"\(([\d\.]+)%",
                        line
                    )

                    if match:
                        paired_pct = match.group(1)

        writer.writerow([
            sample,
            total,
            mapped,
            mapped_pct,
            paired,
            paired_pct
        ])

print("Done! Summary written to: {}".format(outfile))
