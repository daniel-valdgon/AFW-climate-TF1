#---------------------------------------------------------------------------------------------
#	Title: Generate table with hazard and thresholds frequencies from exposure data
# Project: Regional study on exposure to shocks in SSA countries 
#	Author: Bernardo Atuesta
# First written: Oct 10, 2025
#---------------------------------------------------------------------------------------------


# Load required libraries
library(dplyr)
library(tidyr)
library(writexl)

# Load data with exposure indicators at the h3 level
exp_all_h3 <- readRDS("./3_results/exposure/exp_all_h3.rds")

head(exp_all_h3)

# Get distinct combinations
distinct_data <- exp_all %>%
  select(hazard, freq, exp_cat, exp_lab) %>%
  distinct()

# Nest freq and exposure info separately
freq_table <- distinct_data %>%
  select(hazard, freq) %>%
  distinct() %>%
  group_by(hazard) %>%
  arrange(freq) %>%
  mutate(row_id = row_number())

exp_table <- distinct_data %>%
  select(hazard, exp_cat, exp_lab) %>%
  distinct() %>%
  group_by(hazard) %>%
  arrange(exp_cat) %>%
  mutate(row_id = row_number())

# Full join both tables by hazard and row_id
final_table <- full_join(freq_table, exp_table, by = c("hazard", "row_id")) %>%
  arrange(hazard, row_id) %>%
  select(hazard, freq, exp_cat, exp_lab)

# Export to Excel
write_xlsx(final_table, "./3_results/exposure/hazard_exposure_detailed_table.xlsx")




