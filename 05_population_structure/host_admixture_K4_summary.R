library(dplyr)

# Input
dat <- read.table(
  "mapping_admixture_K4_K6_master.tsv",
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

# Summary by host
host_summary <- dat %>%
  group_by(Host) %>%
  summarise(
    N = n(),
    K4_C1_mean = mean(K4_C1, na.rm = TRUE),
    K4_C2_mean = mean(K4_C2, na.rm = TRUE),
    K4_C3_mean = mean(K4_C3, na.rm = TRUE),
    K4_C4_mean = mean(K4_C4, na.rm = TRUE),
    K4_Max_mean = mean(K4_Max, na.rm = TRUE),
    .groups = "drop"
  )

# Save
write.table(
  host_summary,
  "host_admixture_K4_summary.tsv",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

cat("\n============================================\n")
cat("Host ADMIXTURE K=4 summary created\n")
cat("============================================\n\n")

print(host_summary)
