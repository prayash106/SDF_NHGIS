## Create ZIP files to disseminate via IPUMS NHGIS
## 
## - ZIP the CSV(s) and codebook into one ZIP archive

library(tidyverse)
library(zip)

## ---- Constants ----
output_dir <- "data/output"

## ---- Create ZIPs for time varies by column ----
# Generate list of time varies by column files
#file_list <- list.files(output_dir, pattern = "nlcd.csv", full.names = TRUE)
file_list <- list.files(output_dir, pattern = "nhgis_cty_sub", full.names = TRUE)

for(i in file_list){
  
  t <- str_split(i, "/")
  
  # Remove ".csv" from the out_filename
  out_filename <- gsub(".csv", "", t[[1]][3])
  
  # Create the ZIP archive
  zip(paste0("data/output/", out_filename, "_timebycolumn.zip"), files = c(i, "data/output/nhgis_land_cover_summary_README.txt"), mode = "cherry-pick", include_directories = FALSE)
  
}

## ---- Create ZIPs for time varies by file ----
#combos <- c("tract2022_tl2022_nlcd[0-9]", "tract2020_tl2020_nlcd[0-9]", "tract2010_tl2020_nlcd[0-9]", "county2022_tl2022_nlcd[0-9]", "county2020_tl2020_nlcd[0-9]", "county2010_tl2020_nlcd[0-9]", "place2022_tl2022_nlcd[0-9]", "place2020_tl2020_nlcd[0-9]", "place2010_tl2020_nlcd[0-9]")
combos <- c("cty_sub2022_tl2022_nlcd[0-9]", "cty_sub2020_tl2020_nlcd[0-9]", "cty_sub2010_tl2020_nlcd[0-9]")

# Generate list of tiem varies by column files 
for(i in combos){
  
  # Generate list of time varies by file files 
  file_list <- list.files(output_dir, pattern = i, full.names = TRUE)
  
  t <- str_split(file_list[1], "/")
  
  # Remove ".csv" from the out_filename
  out_filename <- gsub(".csv", "", t[[1]][3])
  
  # Remove the last 9 characters from out_filename
  out_filename <- str_sub(out_filename, end = -5)
  
  # Create the ZIP archive
  zip(paste0("data/output/", out_filename, "_timebyfile.zip"), files = c(file_list, "data/output/nhgis_land_cover_summary_README.txt"), mode = "cherry-pick", include_directories = FALSE)
  
}
