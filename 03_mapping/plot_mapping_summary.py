import os
import pandas as pd
import matplotlib.pyplot as plt

# ============================================================
# Plot mapping summary statistics
#
# Input:
#   Mapping/summary/mapping_summary.csv
#
# Output:
#   Mapping/summary/mapping_quality_summary.png
#   Mapping/summary/mapping_quality_summary.pdf
#
# The project directory is detected automatically from the
# location of this script.
# ============================================================

PROJECT_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..")
)

summary_dir = os.path.join(
    PROJECT_DIR,
    "Mapping",
    "summary"
)

input_file = os.path.join(
    summary_dir,
    "mapping_summary.csv"
)

output_png = os.path.join(
    summary_dir,
    "mapping_quality_summary.png"
)

output_pdf = os.path.join(
    summary_dir,
    "mapping_quality_summary.pdf"
)

# Read mapping summary
df = pd.read_csv(input_file)

# Create figure
plt.figure(figsize=(10, 6))

plt.hist(
    df["Mapped_percent"].dropna(),
    bins=20
)

plt.xlabel("Mapped reads (%)")
plt.ylabel("Number of samples")
plt.title("Mapping quality summary")

plt.tight_layout()

# Save figure
plt.savefig(output_png, dpi=300)
plt.savefig(output_pdf)

plt.close()

print("Figures written to:")
print(output_png)
print(output_pdf)
