# ============================================================
# Plot ADMIXTURE K=4 and K=6
# Cactoblastis cactorum RADseq
# ============================================================

library(ggplot2)
library(dplyr)
library(tidyr)

# ------------------------------------------------------------
# Input
# ------------------------------------------------------------

input_file <- "mapping_admixture_K4_K6_master.tsv"

data <- read.table(
  input_file,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Individuals:", nrow(data), "\n")

# ------------------------------------------------------------
# Function to prepare ADMIXTURE data
# ------------------------------------------------------------

prepare_admixture <- function(data, K) {

  cols <- paste0("K", K, "_C", 1:K)

  missing_cols <- cols[!cols %in% colnames(data)]

  if (length(missing_cols) > 0) {
    stop(
      paste(
        "Missing columns:",
        paste(missing_cols, collapse = ", ")
      )
    )
  }

  result <- data %>%
    select(Sample, Pop, all_of(cols)) %>%
    pivot_longer(
      cols = all_of(cols),
      names_to = "Cluster",
      values_to = "Ancestry"
    )

  result$Cluster <- factor(
    result$Cluster,
    levels = cols
  )

  result
}

# ------------------------------------------------------------
# Prepare K=4
# ------------------------------------------------------------

admix_K4 <- prepare_admixture(data, 4)

# ------------------------------------------------------------
# Prepare K=6
# ------------------------------------------------------------

admix_K6 <- prepare_admixture(data, 6)

# ------------------------------------------------------------
# Order individuals by population
# ------------------------------------------------------------

population_order <- data %>%
  arrange(Pop, Sample) %>%
  pull(Sample)

admix_K4$Sample <- factor(
  admix_K4$Sample,
  levels = population_order
)

admix_K6$Sample <- factor(
  admix_K6$Sample,
  levels = population_order
)

# ------------------------------------------------------------
# Plot K=4
# ------------------------------------------------------------

p4 <- ggplot(
  admix_K4,
  aes(
    x = Sample,
    y = Ancestry,
    fill = Cluster
  )
) +
  geom_bar(
    stat = "identity",
    width = 1
  ) +
  labs(
    title = "ADMIXTURE K = 4",
    x = "Individuals",
    y = "Ancestry proportion",
    fill = "Cluster"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0, "lines"),
    legend.position = "right"
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    expand = c(0, 0)
  )

# ------------------------------------------------------------
# Save K=4
# ------------------------------------------------------------

ggsave(
  "ADMIXTURE_K4_individuals.png",
  p4,
  width = 14,
  height = 6,
  dpi = 300
)

ggsave(
  "ADMIXTURE_K4_individuals.pdf",
  p4,
  width = 14,
  height = 6
)

# ------------------------------------------------------------
# Plot K=6
# ------------------------------------------------------------

p6 <- ggplot(
  admix_K6,
  aes(
    x = Sample,
    y = Ancestry,
    fill = Cluster
  )
) +
  geom_bar(
    stat = "identity",
    width = 1
  ) +
  labs(
    title = "ADMIXTURE K = 6",
    x = "Individuals",
    y = "Ancestry proportion",
    fill = "Cluster"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0, "lines"),
    legend.position = "right"
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    expand = c(0, 0)
  )

# ------------------------------------------------------------
# Save K=6
# ------------------------------------------------------------

ggsave(
  "ADMIXTURE_K6_individuals.png",
  p6,
  width = 14,
  height = 6,
  dpi = 300
)

ggsave(
  "ADMIXTURE_K6_individuals.pdf",
  p6,
  width = 14,
  height = 6
)

# ------------------------------------------------------------
# Combined figure K=4 + K=6
# ------------------------------------------------------------

combined <- ggplot(
  bind_rows(
    admix_K4 %>%
      mutate(K = "K = 4"),
    admix_K6 %>%
      mutate(K = "K = 6")
  ),
  aes(
    x = Sample,
    y = Ancestry,
    fill = Cluster
  )
) +
  geom_bar(
    stat = "identity",
    width = 1
  ) +
  facet_grid(
    K ~ .,
    scales = "free_x",
    space = "free_x"
  ) +
  labs(
    title = "ADMIXTURE population structure",
    x = "Individuals",
    y = "Ancestry proportion",
    fill = "Cluster"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold"),
    panel.spacing = unit(0.3, "lines"),
    legend.position = "right"
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    expand = c(0, 0)
  )

# ------------------------------------------------------------
# Save combined figure
# ------------------------------------------------------------

ggsave(
  "ADMIXTURE_K4_K6_combined.png",
  combined,
  width = 14,
  height = 8,
  dpi = 300
)

ggsave(
  "ADMIXTURE_K4_K6_combined.pdf",
  combined,
  width = 14,
  height = 8
)

cat("\n============================================\n")
cat("ADMIXTURE plots successfully created\n")
cat("============================================\n")
cat("ADMIXTURE_K4_individuals.png\n")
cat("ADMIXTURE_K4_individuals.pdf\n")
cat("ADMIXTURE_K6_individuals.png\n")
cat("ADMIXTURE_K6_individuals.pdf\n")
cat("ADMIXTURE_K4_K6_combined.png\n")
cat("ADMIXTURE_K4_K6_combined.pdf\n")
