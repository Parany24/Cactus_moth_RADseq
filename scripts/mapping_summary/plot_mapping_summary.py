import pandas as pd
import matplotlib.pyplot as plt

# Read summary table
df = pd.read_csv("/home/gdobigny/work/Cactus_moth_RADseq/Mapping/summary/mapping_summary.csv")

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(15,5))

# Total reads
axes[0].hist(df["Total_reads"], bins=20)
axes[0].set_title("Total reads")
axes[0].set_xlabel("Reads")
axes[0].set_ylabel("Number of samples")

# % mapped
axes[1].hist(df["Mapped_percent"], bins=20)
axes[1].set_title("% mapped reads")
axes[1].set_xlabel("Percent mapped")

# % properly paired
axes[2].hist(df["Properly_paired_percent"], bins=20)
axes[2].set_title("% properly paired")
axes[2].set_xlabel("Percent properly paired")

plt.tight_layout()

plt.savefig(
"/home/gdobigny/work/Cactus_moth_RADseq/Mapping/summary/mapping_quality_summary.png",
dpi=300)

plt.savefig(
"/home/gdobigny/work/Cactus_moth_RADseq/Mapping/summary/mapping_quality_summary.pdf")

plt.show()
