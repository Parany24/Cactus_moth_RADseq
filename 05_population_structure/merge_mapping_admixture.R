# ============================================================
# Merge mapping information with ADMIXTURE ancestry
# K = 4 and K = 6
# ============================================================

mapping_file <- "mapping_table.tsv"
ancestry_file <- "Stacks/population_structure/individual_ancestry_K4_K6.tsv"

# ------------------------------------------------------------
# Read files
# ------------------------------------------------------------

mapping <- read.table(
    mapping_file,
    header = TRUE,
    sep = "\t",
    stringsAsFactors = FALSE,
    check.names = FALSE,
    fill = TRUE
)

ancestry <- read.table(
    ancestry_file,
    header = TRUE,
    sep = "\t",
    stringsAsFactors = FALSE,
    check.names = FALSE
)

cat("Mapping samples:", nrow(mapping), "\n")
cat("ADMIXTURE samples:", nrow(ancestry), "\n")

# ------------------------------------------------------------
# Check sample names
# ------------------------------------------------------------

common <- intersect(mapping$Sample, ancestry$Individual)

cat("Common samples:", length(common), "\n")

if(length(common) == 0){
    stop("No common sample names found.")
}

# Keep only samples present in both datasets
mapping2 <- mapping[mapping$Sample %in% common, ]
ancestry2 <- ancestry[ancestry$Individual %in% common, ]

# ------------------------------------------------------------
# Preserve ADMIXTURE individual order
# ------------------------------------------------------------

mapping2 <- mapping2[
    match(ancestry2$Individual, mapping2$Sample),
]

# Check
if(!all(mapping2$Sample == ancestry2$Individual)){
    stop("ERROR: sample order does not match.")
}

cat("Sample matching: OK\n")

# ------------------------------------------------------------
# Select useful mapping columns
# ------------------------------------------------------------

mapping_use <- mapping2[, c(
    "Sample",
    "Pop",
    "Locality",
    "Province",
    "Latitude",
    "Longitude",
    "Host"
)]

# ------------------------------------------------------------
# Select useful ADMIXTURE columns
# ------------------------------------------------------------

ancestry_use <- ancestry2[, c(
    "Individual",
    paste0("K4_C", 1:4),
    paste0("K6_C", 1:6),
    "K4_Max",
    "K6_Max",
    "K4_Dominant",
    "K6_Dominant",
    "K4_Category",
    "K6_Category"
)]

# ------------------------------------------------------------
# Rename Individual -> Sample
# ------------------------------------------------------------

names(ancestry_use)[names(ancestry_use) == "Individual"] <- "Sample"

# ------------------------------------------------------------
# Merge
# ------------------------------------------------------------

master <- merge(
    mapping_use,
    ancestry_use,
    by = "Sample",
    sort = FALSE
)

# ------------------------------------------------------------
# Check
# ------------------------------------------------------------

cat("Final number of samples:", nrow(master), "\n")
cat("Final number of columns:", ncol(master), "\n")

# ------------------------------------------------------------
# Order by population
# ------------------------------------------------------------

master <- master[order(master$Pop, master$Sample), ]

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------

output <- "mapping_admixture_K4_K6_master.tsv"

write.table(
    master,
    output,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
)

cat("\nFile created:\n")
cat(output, "\n")

# ------------------------------------------------------------
# Population summary
# ------------------------------------------------------------

pop_summary <- aggregate(
    cbind(K4_Max, K6_Max) ~ Pop,
    data = master,
    FUN = mean
)

names(pop_summary) <- c(
    "Population",
    "Mean_max_ancestry_K4",
    "Mean_max_ancestry_K6"
)

write.table(
    pop_summary,
    "population_mean_ancestry_K4_K6.tsv",
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
)

cat("Population summary created:\n")
cat("population_mean_ancestry_K4_K6.tsv\n")
