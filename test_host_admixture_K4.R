library(dplyr)

# ============================================================
# Test association HOST - ADMIXTURE K=4
# Contrôle de la population
# ============================================================

input_file <- "mapping_admixture_K4_K6_master.tsv"

# ------------------------------------------------------------
# Read data
# ------------------------------------------------------------

data <- read.delim(
  input_file,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Individuals:", nrow(data), "\n")
cat("Populations:", length(unique(data$Pop)), "\n")
cat("Hosts:", length(unique(data$Host)), "\n\n")

# ------------------------------------------------------------
# Required columns
# ------------------------------------------------------------

required <- c(
  "Sample",
  "Pop",
  "Host",
  "K4_C1",
  "K4_C2",
  "K4_C3",
  "K4_C4"
)

missing <- setdiff(required, colnames(data))

if (length(missing) > 0) {
  stop(
    paste(
      "Missing columns:",
      paste(missing, collapse = ", ")
    )
  )
}

# ------------------------------------------------------------
# Remove missing data
# ------------------------------------------------------------

data <- data %>%
  filter(
    !is.na(Host),
    !is.na(Pop),
    !is.na(K4_C1),
    !is.na(K4_C2),
    !is.na(K4_C3),
    !is.na(K4_C4)
  )

cat("Complete individuals:", nrow(data), "\n\n")

# ============================================================
# 1. Simple association: ancestry ~ HOST
# ============================================================

cat("============================================\n")
cat("1. Association between HOST and ancestry\n")
cat("============================================\n\n")

for (cluster in c("K4_C1", "K4_C2", "K4_C3", "K4_C4")) {

  formula <- as.formula(
    paste(cluster, "~ Host")
  )

  model <- lm(formula, data = data)

  cat("\n", cluster, "\n")
  print(anova(model))

  r2 <- summary(model)$r.squared

  cat("R-squared =", round(r2, 4), "\n")
}

# ============================================================
# 2. Association: ancestry ~ POPULATION
# ============================================================

cat("\n============================================\n")
cat("2. Association between POPULATION and ancestry\n")
cat("============================================\n\n")

for (cluster in c("K4_C1", "K4_C2", "K4_C3", "K4_C4")) {

  formula <- as.formula(
    paste(cluster, "~ Pop")
  )

  model <- lm(formula, data = data)

  cat("\n", cluster, "\n")
  print(anova(model))

  r2 <- summary(model)$r.squared

  cat("R-squared =", round(r2, 4), "\n")
}

# ============================================================
# 3. HOST effect while controlling for POPULATION
# ============================================================

cat("\n============================================\n")
cat("3. HOST effect after controlling for POPULATION\n")
cat("============================================\n\n")

results <- data.frame()

for (cluster in c("K4_C1", "K4_C2", "K4_C3", "K4_C4")) {

  # Model without host
  model_pop <- lm(
    as.formula(paste(cluster, "~ Pop")),
    data = data
  )

  # Model with host
  model_pop_host <- lm(
    as.formula(paste(cluster, "~ Pop + Host")),
    data = data
  )

  # Compare models
  comparison <- anova(
    model_pop,
    model_pop_host
  )

  p_value <- comparison$`Pr(>F)`[2]

  r2_pop <- summary(model_pop)$r.squared
  r2_full <- summary(model_pop_host)$r.squared

  delta_r2 <- r2_full - r2_pop

  results <- rbind(
    results,
    data.frame(
      Cluster = cluster,
      P_value_host = p_value,
      R2_population = r2_pop,
      R2_population_host = r2_full,
      Delta_R2_host = delta_r2
    )
  )

  cat("\n", cluster, "\n")
  print(comparison)

  cat(
    "Host P-value =", 
    format.pval(p_value, digits = 4),
    "\n"
  )

  cat(
    "Additional R2 explained by Host =",
    round(delta_r2, 4),
    "\n"
  )
}

# ------------------------------------------------------------
# Multiple-testing correction
# ------------------------------------------------------------

results$P_adjusted_BH <- p.adjust(
  results$P_value_host,
  method = "BH"
)

# ------------------------------------------------------------
# Save results
# ------------------------------------------------------------

write.table(
  results,
  "host_effect_K4_control_population.tsv",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

cat("\n============================================\n")
cat("FINAL RESULTS\n")
cat("============================================\n\n")

print(results)

cat("\nFile created:\n")
cat("host_effect_K4_control_population.tsv\n")
