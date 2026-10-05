library(dplyr)

# ============================================================
# Population assignment summary at K=4 and K=6
# Thresholds: 80%, 90%, 95%
# ============================================================

input <- "mapping_admixture_K4_K6_master.tsv"

# Read data
dat <- read.table(
  input,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Individuals:", nrow(dat), "\n")
cat("Populations:", length(unique(dat$Pop)), "\n")

# ------------------------------------------------------------
# K4 and K6 maximum ancestry
# ------------------------------------------------------------

dat <- dat %>%
  mutate(
    K4_Max = as.numeric(K4_Max),
    K6_Max = as.numeric(K6_Max)
  )

# ------------------------------------------------------------
# Calculate population-level statistics
# ------------------------------------------------------------

summary_table <- dat %>%
  group_by(Pop) %>%
  summarise(
    
    N = n(),
    
    # ---------------- K4 ----------------
    K4_ge80_n = sum(K4_Max >= 0.80, na.rm = TRUE),
    K4_ge80_pct = round(100 * K4_ge80_n / N, 1),
    
    K4_ge90_n = sum(K4_Max >= 0.90, na.rm = TRUE),
    K4_ge90_pct = round(100 * K4_ge90_n / N, 1),
    
    K4_ge95_n = sum(K4_Max >= 0.95, na.rm = TRUE),
    K4_ge95_pct = round(100 * K4_ge95_n / N, 1),
    
    K4_lt80_n = sum(K4_Max < 0.80, na.rm = TRUE),
    K4_lt80_pct = round(100 * K4_lt80_n / N, 1),
    
    # ---------------- K6 ----------------
    K6_ge80_n = sum(K6_Max >= 0.80, na.rm = TRUE),
    K6_ge80_pct = round(100 * K6_ge80_n / N, 1),
    
    K6_ge90_n = sum(K6_Max >= 0.90, na.rm = TRUE),
    K6_ge90_pct = round(100 * K6_ge90_n / N, 1),
    
    K6_ge95_n = sum(K6_Max >= 0.95, na.rm = TRUE),
    K6_ge95_pct = round(100 * K6_ge95_n / N, 1),
    
    K6_lt80_n = sum(K6_Max < 0.80, na.rm = TRUE),
    K6_lt80_pct = round(100 * K6_lt80_n / N, 1),
    
    .groups = "drop"
  )

# ------------------------------------------------------------
# Write output
# ------------------------------------------------------------

write.table(
  summary_table,
  "population_assignment_thresholds_K4_K6.tsv",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

cat("\n============================================\n")
cat("Population assignment summary created\n")
cat("============================================\n")
cat("File:\n")
cat("population_assignment_thresholds_K4_K6.tsv\n\n")

print(summary_table)
