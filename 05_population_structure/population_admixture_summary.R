# ============================================================
# Population-level ADMIXTURE summary
# K = 4 and K = 6
# ============================================================

file <- "mapping_admixture_K4_K6_master.tsv"

dat <- read.table(
    file,
    header = TRUE,
    sep = "\t",
    stringsAsFactors = FALSE,
    check.names = FALSE
)

cat("Individuals:", nrow(dat), "\n")
cat("Populations:", length(unique(dat$Pop)), "\n\n")

# ------------------------------------------------------------
# Function to calculate population summaries
# ------------------------------------------------------------

make_summary <- function(data, K) {

    clusters <- paste0("K", K, "_C", 1:K)

    results <- data.frame()

    for (pop in unique(data$Pop)) {

        x <- data[data$Pop == pop, ]

        means <- colMeans(x[, clusters], na.rm = TRUE)

        dominant <- which.max(means)
        max_mean <- max(means)

        row <- data.frame(
            Population = pop,
            N = nrow(x)
        )

        for (i in 1:K) {
            row[[paste0("K", K, "_C", i, "_mean")]] <-
                round(means[i], 4)
        }

        row[[paste0("K", K, "_Dominant")]] <- dominant
        row[[paste0("K", K, "_Max_mean")]] <- round(max_mean, 4)

        results <- rbind(results, row)
    }

    return(results)
}

# ------------------------------------------------------------
# K4 and K6
# ------------------------------------------------------------

K4 <- make_summary(dat, 4)
K6 <- make_summary(dat, 6)

# ------------------------------------------------------------
# Merge
# ------------------------------------------------------------

summary <- merge(
    K4,
    K6,
    by = c("Population", "N"),
    sort = FALSE
)

summary <- summary[order(summary$Population), ]

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------

write.table(
    summary,
    "population_admixture_summary_K4_K6.tsv",
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
)

cat("File created:\n")
cat("population_admixture_summary_K4_K6.tsv\n\n")

# ------------------------------------------------------------
# Display
# ------------------------------------------------------------

print(summary)
