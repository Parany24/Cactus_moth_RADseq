import os
import re
import csv
from glob import glob

stats_dir = "/home/gdobigny/work/Cactus_moth_RADseq/Mapping/stats"
outfile = "/home/gdobigny/work/Cactus_moth_RADseq/Mapping/summary/mapping_summary.csv"

files = sorted(glob(os.path.join(stats_dir, "*.flagstat.txt")))

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

        sample = os.path.basename(f).replace(".flagstat.txt","")

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
                    mapped_pct = re.search(r"\(([\d\.]+)%", line).group(1)

                elif "properly paired" in line:
                    paired = line.split()[0]
                    paired_pct = re.search(r"\(([\d\.]+)%", line).group(1)

        writer.writerow([
            sample,
            total,
            mapped,
            mapped_pct,
            paired,
            paired_pct
        ])

print("Done!")
