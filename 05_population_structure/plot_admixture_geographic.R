library(ggplot2)
library(dplyr)
library(tidyr)

# ============================================================
# ADMIXTURE plots ordered by geographic position
# Cactoblastis cactorum
# K = 4 and K = 6
# ============================================================

# Input file
input_file <- "mapping_admixture_K4_K6_master.tsv"

# Read data
dat <- read.table(
  input_file,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Individuals:", nrow(dat), "\n")

# ------------------------------------------------------------
# Geographic population order: north -> south
# ------------------------------------------------------------

pop_order <- c(
  "FOG",
  "CHP",
  "JUS",
  "JUJ",
  "TUN",
  "SEP",
  "SEL",
  "SEB",
  "CAQ",
  "CAS",
  "CBA",
  "CBF",
  "CBR",
  "CBV",
  "CBS",
  "ERN",
  "ERB",
  "ERC",
  "ERL",
  "ERD",
  "ERF",
  "LPA",
  "LPV",
  "LPS",
  "BAM",
  "BAP",
  "BAS",
  "RNR"
)

# Check that all populations are present
missing_pops <- setdiff(pop_order, unique(dat$Pop))

if(length(missing_pops) > 0) {
  cat("WARNING: populations missing from dataset:\n")
  print(missing_pops)
}

# Keep only populations present in data
pop_order <- pop_order[pop_order %in% unique(dat$Pop)]

# ------------------------------------------------------------
# Order individuals by population
# ------------------------------------------------------------

dat$Pop <- factor(dat$Pop, levels = pop_order)

dat <- dat %>%
  arrange(Pop, Sample)

dat$Individual <- seq_len(nrow(dat))

# ------------------------------------------------------------
# Function to prepare ADMIXTURE data
# ------------------------------------------------------------

prepare_admixture <- function(data, K) {

  cols <- paste0("K", K, "_C", 1:K)

  long <- data %>%
    select(Individual, Sample, Pop, all_of(cols)) %>%
    pivot_longer(
      cols = all_of(cols),
      names_to = "Cluster",
      values_to = "Ancestry"
    )

  long$Cluster <- factor(
    long$Cluster,
    levels = cols
  )

  return(long)
}

# ------------------------------------------------------------
# Function to create plot
# ------------------------------------------------------------

make_plot <- function(data, K) {

  long <- prepare_admixture(data, K)

  # Population boundaries
  pop_sizes <- table(data$Pop)

  boundaries <- cumsum(as.numeric(pop_sizes))

  boundaries <- boundaries[-length(boundaries)]

  # Population centres for labels
  pop_centres <- data %>%
    group_by(Pop) %>%
    summarise(
      xmin = min(Individual),
      xmax = max(Individual),
      centre = (xmin + xmax) / 2,
      .groups = "drop"
    )

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

    # Population separators
    geom_vline(
      xintercept = boundaries + 0.5,
      linewidth = 0.25,
      colour = "black"
    ) +

    # Population labels
    annotate(
      "text",
      x = pop_centres$centre,
      y = -0.07,
      label = as.character(pop_centres$Pop),
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      size = 2.8
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
      fill = "Cluster",
      title = paste0("ADMIXTURE K = ", K)
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

  return(p)
}

# ------------------------------------------------------------
# Create K4
# ------------------------------------------------------------

p4 <- make_plot(dat, 4)

ggsave(
  "ADMIXTURE_K4_geographic.png",
  p4,
  width = 14,
  height = 5,
  dpi = 300
)

ggsave(
  "ADMIXTURE_K4_geographic.pdf",
  p4,
  width = 14,
  height = 5
)

# ------------------------------------------------------------
# Create K6
# ------------------------------------------------------------

p6 <- make_plot(dat, 6)

ggsave(
  "ADMIXTURE_K6_geographic.png",
  p6,
  width = 14,
  height = 5,
  dpi = 300
)

ggsave(
  "ADMIXTURE_K6_geographic.pdf",
  p6,
  width = 14,
  height = 5
)

# ------------------------------------------------------------
# Combined K4 + K6
# ------------------------------------------------------------

if(requireNamespace("patchwork", quietly = TRUE)) {

  library(patchwork)

  combined <- p4 / p6

  ggsave(
    "ADMIXTURE_K4_K6_geographic.png",
    combined,
    width = 14,
    height = 9,
    dpi = 300
  )

  ggsave(
    "ADMIXTURE_K4_K6_geographic.pdf",
    combined,
    width = 14,
    height = 9
  )

  cat("\nCombined figure created.\n")

} else {

  cat("\nPackage 'patchwork' is not installed.\n")
  cat("K4 and K6 figures were created separately.\n")
}

cat("\n============================================\n")
cat("ADMIXTURE geographic plots successfully created\n")
cat("============================================\n")

cat("ADMIXTURE_K4_geographic.png\n")
cat("ADMIXTURE_K4_geographic.pdf\n")
cat("ADMIXTURE_K6_geographic.png\n")
cat("ADMIXTURE_K6_geographic.pdf\n")
