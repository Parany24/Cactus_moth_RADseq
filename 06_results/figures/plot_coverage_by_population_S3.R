#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(patchwork)
  library(RColorBrewer)
})

# ============================================================
# Supplementary Figure S3
# Coverage statistics per individual grouped by population
#
# Input:
#   Coverage/coverage_summary.tsv
#   mapping_table.tsv
#
# Output:
#   Coverage/Figure_S3_coverage_by_population_colored_ascending.pdf
#   Coverage/Figure_S3_coverage_by_population_colored_ascending.png
#   Coverage/coverage_summary_overall.tsv
#   Coverage/coverage_summary_by_population.tsv
# ============================================================

coverage <- read_tsv("Coverage/coverage_summary.tsv", show_col_types = FALSE)
metadata <- read_tsv("mapping_table.tsv", show_col_types = FALSE)

df <- coverage %>%
  left_join(metadata %>% select(SRA, Sample, Pop, Locality, Province, Latitude, Longitude, Host), by = "SRA") %>%
  mutate(
    genome_wide_mean_depth = as.numeric(genome_wide_mean_depth),
    covered_bases = as.numeric(covered_bases),
    breadth_covered_percent = as.numeric(breadth_covered_percent),
    mean_depth_covered_sites = as.numeric(mean_depth_covered_sites),
    Pop = as.factor(Pop)
  )

# Check missing metadata
missing_meta <- df %>% filter(is.na(Pop))
if (nrow(missing_meta) > 0) {
  warning("Some samples in coverage_summary.tsv are missing from mapping_table.tsv:")
  print(missing_meta$SRA)
}

# Order populations ascending by mean genome-wide coverage
pop_order <- df %>%
  group_by(Pop) %>%
  summarise(
    mean_genome_wide_depth = mean(genome_wide_mean_depth, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(mean_genome_wide_depth) %>%
  pull(Pop)

df <- df %>%
  mutate(Pop = factor(Pop, levels = pop_order))

# Overall summary
coverage_summary_overall <- df %>%
  summarise(
    n_samples = n(),

    mean_genome_wide_depth = mean(genome_wide_mean_depth, na.rm = TRUE),
    sd_genome_wide_depth = sd(genome_wide_mean_depth, na.rm = TRUE),

    mean_breadth_covered_percent = mean(breadth_covered_percent, na.rm = TRUE),
    sd_breadth_covered_percent = sd(breadth_covered_percent, na.rm = TRUE),

    mean_depth_covered_sites = mean(mean_depth_covered_sites, na.rm = TRUE),
    sd_depth_covered_sites = sd(mean_depth_covered_sites, na.rm = TRUE)
  )

# Population-level summary
coverage_summary_by_pop <- df %>%
  group_by(Pop) %>%
  summarise(
    n_samples = n(),

    mean_genome_wide_depth = mean(genome_wide_mean_depth, na.rm = TRUE),
    sd_genome_wide_depth = sd(genome_wide_mean_depth, na.rm = TRUE),

    mean_breadth_covered_percent = mean(breadth_covered_percent, na.rm = TRUE),
    sd_breadth_covered_percent = sd(breadth_covered_percent, na.rm = TRUE),

    mean_depth_covered_sites = mean(mean_depth_covered_sites, na.rm = TRUE),
    sd_depth_covered_sites = sd(mean_depth_covered_sites, na.rm = TRUE),

    .groups = "drop"
  )

write_tsv(coverage_summary_overall, "Coverage/coverage_summary_overall.tsv")
write_tsv(coverage_summary_by_pop, "Coverage/coverage_summary_by_population.tsv")

# Colors
n_pops <- length(levels(df$Pop))

base_cols <- c(
  brewer.pal(8, "Dark2"),
  brewer.pal(8, "Set2"),
  brewer.pal(12, "Paired")
)

pop_cols <- colorRampPalette(base_cols)(n_pops)
names(pop_cols) <- levels(df$Pop)

theme_paper <- theme_bw(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      vjust = 1,
      size = 8
    ),
    axis.title = element_text(size = 10),
    plot.title = element_text(face = "bold", size = 11),
    legend.position = "none"
  )

# Panel A: genome-wide mean depth
p1 <- ggplot(df, aes(x = Pop, y = genome_wide_mean_depth, color = Pop)) +
  geom_boxplot(aes(fill = Pop), outlier.shape = NA, linewidth = 0.3, alpha = 0.25) +
  geom_jitter(width = 0.18, size = 1.7, alpha = 0.85) +
  scale_color_manual(values = pop_cols) +
  scale_fill_manual(values = pop_cols) +
  labs(
    title = "A. Genome-wide mean depth",
    x = NULL,
    y = "Mean depth across reference genome (×)"
  ) +
  theme_paper

# Panel B: breadth of coverage
p2 <- ggplot(df, aes(x = Pop, y = breadth_covered_percent, color = Pop)) +
  geom_boxplot(aes(fill = Pop), outlier.shape = NA, linewidth = 0.3, alpha = 0.25) +
  geom_jitter(width = 0.18, size = 1.7, alpha = 0.85) +
  scale_color_manual(values = pop_cols) +
  scale_fill_manual(values = pop_cols) +
  labs(
    title = "B. Breadth of coverage",
    x = NULL,
    y = "Reference genome covered at ≥1× (%)"
  ) +
  theme_paper

# Panel C: mean depth at covered sites
p3 <- ggplot(df, aes(x = Pop, y = mean_depth_covered_sites, color = Pop)) +
  geom_boxplot(aes(fill = Pop), outlier.shape = NA, linewidth = 0.3, alpha = 0.25) +
  geom_jitter(width = 0.18, size = 1.7, alpha = 0.85) +
  scale_color_manual(values = pop_cols) +
  scale_fill_manual(values = pop_cols) +
  labs(
    title = "C. Mean depth at covered sites",
    x = "Population",
    y = "Mean depth at covered positions (×)"
  ) +
  theme_paper

fig <- p1 / p2 / p3 + plot_layout(heights = c(1, 1, 1))

ggsave(
  filename = "Coverage/Figure_S3_coverage_by_population_colored_ascending.pdf",
  plot = fig,
  width = 12,
  height = 10
)

ggsave(
  filename = "Coverage/Figure_S3_coverage_by_population_colored_ascending.png",
  plot = fig,
  width = 12,
  height = 10,
  dpi = 300
)

cat("\nCoverage summary overall:\n")
print(coverage_summary_overall)

cat("\nFigure saved:\n")
cat("Coverage/Figure_S3_coverage_by_population_colored_ascending.pdf\n")
cat("Coverage/Figure_S3_coverage_by_population_colored_ascending.png\n")
