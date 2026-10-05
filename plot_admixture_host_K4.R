library(ggplot2)
library(dplyr)
library(tidyr)

# ============================================================
# ADMIXTURE K=4 grouped by host
# ============================================================

input_file <- "mapping_admixture_K4_K6_master.tsv"

dat <- read.table(
  input_file,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Individuals:", nrow(dat), "\n")

# ------------------------------------------------------------
# Host order
# ------------------------------------------------------------

host_order <- c(
  "O. ficus-indica",
  "O. megapotamica",
  "O. elata",
  "O. rioplatense",
  "O. penicilligera",
  "O. anacantha",
  "O. quimilo",
  "O. bonaerensis"
)

# Keep only hosts actually present
host_order <- host_order[
  host_order %in% unique(dat$Host)
]

# ------------------------------------------------------------
# Order individuals by host, then population
# ------------------------------------------------------------

dat$Host <- factor(
  dat$Host,
  levels = host_order
)

dat <- dat %>%
  arrange(Host, Pop, Sample)

dat$Individual <- seq_len(nrow(dat))

# ------------------------------------------------------------
# Convert to long format
# ------------------------------------------------------------

long <- dat %>%
  select(
    Individual,
    Sample,
    Host,
    Pop,
    K4_C1,
    K4_C2,
    K4_C3,
    K4_C4
  ) %>%
  pivot_longer(
    cols = c(K4_C1, K4_C2, K4_C3, K4_C4),
    names_to = "Cluster",
    values_to = "Ancestry"
  )

long$Cluster <- factor(
  long$Cluster,
  levels = c("K4_C1", "K4_C2", "K4_C3", "K4_C4")
)

# ------------------------------------------------------------
# Host boundaries
# ------------------------------------------------------------

host_sizes <- table(dat$Host)

host_boundaries <- cumsum(
  as.numeric(host_sizes)
)

host_boundaries <- host_boundaries[
  -length(host_boundaries)
]

# Host centres
host_centres <- dat %>%
  group_by(Host) %>%
  summarise(
    xmin = min(Individual),
    xmax = max(Individual),
    centre = (xmin + xmax) / 2,
    .groups = "drop"
  )

# ------------------------------------------------------------
# Plot
# ------------------------------------------------------------

p <- ggplot(
  long,
  aes(
    x = Individual,
    y = Ancestry,
    fill = Cluster
  )
) +

  geom_bar(
    stat = "identity",
    width = 1
  ) +

  geom_vline(
    xintercept = host_boundaries + 0.5,
    linewidth = 0.3
  ) +

  annotate(
    "text",
    x = host_centres$centre,
    y = -0.08,
    label = as.character(host_centres$Host),
    angle = 90,
    hjust = 1,
    vjust = 0.5,
    size = 3
  ) +

  scale_x_continuous(
    breaks = NULL,
    expand = c(0, 0)
  ) +

  scale_y_continuous(
    limits = c(-0.12, 1),
    breaks = c(0, 0.25, 0.5, 0.75, 1),
    expand = c(0, 0)
  ) +

  labs(
    x = NULL,
    y = "Ancestry proportion",
    fill = "ADMIXTURE cluster",
    title = "ADMIXTURE K = 4 by host"
  ) +

  theme_classic() +

  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 14
    ),

    axis.title.y = element_text(
      size = 11
    ),

    axis.text.y = element_text(
      size = 9
    ),

    axis.text.x = element_blank(),

    axis.ticks.x = element_blank(),

    legend.position = "right",

    legend.title = element_text(
      size = 10
    ),

    legend.text = element_text(
      size = 9
    ),

    plot.margin = margin(
      10, 10, 10, 10
    )
  )

# ------------------------------------------------------------
# Save PNG and PDF
# ------------------------------------------------------------

ggsave(
  "ADMIXTURE_K4_by_host.png",
  p,
  width = 14,
  height = 5,
  dpi = 300
)

ggsave(
  "ADMIXTURE_K4_by_host.pdf",
  p,
  width = 14,
  height = 5
)

cat("\n============================================\n")
cat("ADMIXTURE K=4 host figure created\n")
cat("============================================\n")
cat("ADMIXTURE_K4_by_host.png\n")
cat("ADMIXTURE_K4_by_host.pdf\n")
