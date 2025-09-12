## Saving some files in different formats for sharing and exploring 

# Load library
library(haven)

setwd("C:/Users/wb384997/OneDrive - WBG/Documents/Climate Change/Regional study on Exposure to shocks/Shared folders/West_Africa_Exposure/3_results/hhss-exposure/BEN")

survey <- read_dta("./RS_BEN_se_geocode_h3.dta")

# Save in R format
saveRDS(survey, "./RS_BEN_se_geocode_h3.rds")        # saves as .rds

# Save as CSV
write.csv(survey, "./RS_BEN_se_geocode_h3.csv", row.names = FALSE)


# Extract the first 10 observations
first_10 <- head(survey, 10)

# Save to a new file
write.csv(first_10, "./RS_BEN_se_geocode_h3.csv", row.names = FALSE)
