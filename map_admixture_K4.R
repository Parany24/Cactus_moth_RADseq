# ============================================================
# ADMIXTURE K=4 - GEOGRAPHICAL MAP
# Base R only - no ggplot2 / sf required
# ============================================================

input_file <- "mapping_admixture_K4_K6_master.tsv"

# ------------------------------------------------------------
# Read data
# ------------------------------------------------------------

dat <- read.table(
  input_file,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Individuals:", nrow(dat), "\n")
cat("Populations:", length(unique(dat$Pop)), "\n")

# ------------------------------------------------------------
# Select variables
# ------------------------------------------------------------

dat <- dat[, c(
  "Sample",
  "Pop",
  "Locality",
  "Province",
  "Latitude",
  "Longitude",
  "K4_C1",
  "K4_C2",
  "K4_C3",
  "K4_C4"
)]

# ------------------------------------------------------------
# Convert numeric variables
# ------------------------------------------------------------

dat$Latitude  <- as.numeric(dat$Latitude)
dat$Longitude <- as.numeric(dat$Longitude)

dat$K4_C1 <- as.numeric(dat$K4_C1)
dat$K4_C2 <- as.numeric(dat$K4_C2)
dat$K4_C3 <- as.numeric(dat$K4_C3)
dat$K4_C4 <- as.numeric(dat$K4_C4)

# ------------------------------------------------------------
# Population means
# ------------------------------------------------------------

pop_names <- unique(dat$Pop)

pop <- data.frame()

for (p in pop_names) {

  x <- dat[dat$Pop == p, ]

  row <- data.frame(
    Pop = p,
    N = nrow(x),
    Locality = x$Locality[1],
    Province = x$Province[1],
    Latitude = mean(x$Latitude, na.rm = TRUE),
    Longitude = mean(x$Longitude, na.rm = TRUE),
    K4_C1 = mean(x$K4_C1, na.rm = TRUE),
    K4_C2 = mean(x$K4_C2, na.rm = TRUE),
    K4_C3 = mean(x$K4_C3, na.rm = TRUE),
    K4_C4 = mean(x$K4_C4, na.rm = TRUE)
  )

  pop <- rbind(pop, row)
}

cat("Populations used in map:", nrow(pop), "\n")

# ------------------------------------------------------------
# Geographic order: north -> south
# ------------------------------------------------------------

pop <- pop[order(-pop$Latitude), ]

# ------------------------------------------------------------
# Colors for K=4
# ------------------------------------------------------------

cluster_colors <- c(
  "#E69F00",
  "#56B4E9",
  "#009E73",
  "#CC79A7"
)

# ------------------------------------------------------------
# Create PNG
# ------------------------------------------------------------

png(
  "ADMIXTURE_K4_geographic_population.png",
  width = 3000,
  height = 3000,
  res = 300
)

par(
  mar = c(5, 5, 5, 8),
  xpd = TRUE
)

# Empty geographic plot

plot(
  pop$Longitude,
  pop$Latitude,
  type = "n",
  xlim = c(-71, -57),
  ylim = c(-40, -22),
  xlab = "Longitude",
  ylab = "Latitude",
  main = "Geographical distribution of ADMIXTURE ancestry\nCactoblastis cactorum — K = 4",
  cex.main = 1.5,
  cex.lab = 1.2
)

# Grid

grid(
  nx = 7,
  ny = 7,
  col = "lightgray",
  lty = 3
)

# ------------------------------------------------------------
# Draw stacked ancestry bars
# ------------------------------------------------------------

bar_width <- 0.35
bar_height <- 0.65

for (i in 1:nrow(pop)) {

  x <- pop$Longitude[i]
  y <- pop$Latitude[i]

  ancestry <- c(
    pop$K4_C1[i],
    pop$K4_C2[i],
    pop$K4_C3[i],
    pop$K4_C4[i]
  )

  # Normalize to exactly 1
  ancestry <- ancestry / sum(ancestry)

  cumulative <- c(0, cumsum(ancestry))

  for (j in 1:4) {

    rect(
      xleft = x - bar_width / 2,
      xright = x + bar_width / 2,
      ybottom = y + cumulative[j] * bar_height,
      ytop = y + cumulative[j + 1] * bar_height,
      col = cluster_colors[j],
      border = "white"
    )
  }

  # Population name

  text(
    x,
    y + bar_height + 0.35,
    labels = pop$Pop[i],
    cex = 0.8,
    font = 2
  )

  # Population location

  points(
    x,
    y,
    pch = 21,
    bg = "white",
    col = "black",
    cex = 0.5
  )
}

# ------------------------------------------------------------
# Legend
# ------------------------------------------------------------

legend(
  "topright",
  legend = c(
    "Cluster 1",
    "Cluster 2",
    "Cluster 3",
    "Cluster 4"
  ),
  fill = cluster_colors,
  title = "ADMIXTURE",
  bty = "n",
  cex = 1
)

dev.off()

# ------------------------------------------------------------
# PDF
# ------------------------------------------------------------

pdf(
  "ADMIXTURE_K4_geographic_population.pdf",
  width = 10,
  height = 10
)

par(
  mar = c(5, 5, 5, 8),
  xpd = TRUE
)

plot(
  pop$Longitude,
  pop$Latitude,
  type = "n",
  xlim = c(-71, -57),
  ylim = c(-40, -22),
  xlab = "Longitude",
  ylab = "Latitude",
  main = "Geographical distribution of ADMIXTURE ancestry\nCactoblastis cactorum — K = 4"
)

grid(
  nx = 7,
  ny = 7,
  col = "lightgray",
  lty = 3
)

for (i in 1:nrow(pop)) {

  x <- pop$Longitude[i]
  y <- pop$Latitude[i]

  ancestry <- c(
    pop$K4_C1[i],
    pop$K4_C2[i],
    pop$K4_C3[i],
    pop$K4_C4[i]
  )

  ancestry <- ancestry / sum(ancestry)

  cumulative <- c(0, cumsum(ancestry))

  for (j in 1:4) {

    rect(
      xleft = x - bar_width / 2,
      xright = x + bar_width / 2,
      ybottom = y + cumulative[j] * bar_height,
      ytop = y + cumulative[j + 1] * bar_height,
      col = cluster_colors[j],
      border = "white"
    )
  }

  text(
    x,
    y + bar_height + 0.35,
    labels = pop$Pop[i],
    cex = 0.8,
    font = 2
  )
}

legend(
  "topright",
  legend = c(
    "Cluster 1",
    "Cluster 2",
    "Cluster 3",
    "Cluster 4"
  ),
  fill = cluster_colors,
  title = "ADMIXTURE",
  bty = "n"
)

dev.off()

# ------------------------------------------------------------
# Finished
# ------------------------------------------------------------

cat("\n============================================\n")
cat("ADMIXTURE K=4 geographical figure created\n")
cat("============================================\n")
cat("Populations:", nrow(pop), "\n")
cat("PNG: ADMIXTURE_K4_geographic_population.png\n")
cat("PDF: ADMIXTURE_K4_geographic_population.pdf\n")
