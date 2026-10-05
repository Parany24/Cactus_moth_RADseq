library(dplyr)

# ============================================================
# Preparation of population-level ADMIXTURE K=4 map data
# ============================================================

input_file <- "mapping_admixture_K4_K6_master.tsv"

data <- read.delim(
  input_file,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Individuals:", nrow(data), "\n")
cat("Populations:", length(unique(data$Pop)), "\n")

# ------------------------------------------------------------
# Population summary
# ------------------------------------------------------------

pop_map <- data %>%
  group_by(Pop) %>%
  summarise(
    N = n(),

    Locality = first(Locality),
    Province = first(Province),

    Latitude = mean(as.numeric(Latitude), na.rm = TRUE),
    Longitude = mean(as.numeric(Longitude), na.rm = TRUE),

    K4_C1 = mean(K4_C1, na.rm = TRUE),
    K4_C2 = mean(K4_C2, na.rm = TRUE),
    K4_C3 = mean(K4_C3, na.rm = TRUE),
    K4_C4 = mean(K4_C4, na.rm = TRUE),

    .groups = "drop"
  )

# ------------------------------------------------------------
# Dominant cluster
# ------------------------------------------------------------

pop_map$K4_Dominant <- apply(
  pop_map[, c("K4_C1", "K4_C2", "K4_C3", "K4_C4")],
  1,
  which.max
)

# Maximum ancestry proportion

pop_map$K4_Max <- apply(
  pop_map[, c("K4_C1", "K4_C2", "K4_C3", "K4_C4")],
  1,
  max
)

# ------------------------------------------------------------
# Order by latitude
# ------------------------------------------------------------

pop_map <- pop_map %>%
  arrange(desc(Latitude))

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------

write.table(
  pop_map,
  "population_map_K4.tsv",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

cat("\n============================================\n")
cat("Population map table created\n")
cat("============================================\n")

cat("Number of populations:", nrow(pop_map), "\n")
cat("File: population_map_K4.tsv\n\n")

print(pop_map)
