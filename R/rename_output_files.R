## Rename output files based on Jonathan's suggestions

library(tidyverse)

options(scipen = 999)

## ---- Constants ----
output_dir <- "data/output"

## ---- List files in output_dir ----
file_list <- list.files(output_dir, pattern = "cty_sub", full.names = TRUE)

## ---- Rename CSV files ----
# for(i in file_list){
#   
#   x <- read_csv(i)
#   
#   t <- str_split(i, "_")
#   
#   t[[1]][1] <- gsub("US", "nhgis", t[[1]][1])
#   
#   if(lengths(t) == 5){
#     
#     # Generate a new file name based on Jonathan's suggestions - specific NLCD years  
#     new_file_name <- paste0(t[[1]][1], "_", t[[1]][2], t[[1]][3], "_", t[[1]][4], "_", t[[1]][5])
#     
#   } else{
#     
#     # Generate a new file name based on Jonathan's suggestions - specific NLCD years  
#     new_file_name <- paste0(t[[1]][1], "_", t[[1]][2], t[[1]][3], "_", t[[1]][4], "_", t[[1]][5], t[[1]][6])
#   }
# 
#   write_csv(x, new_file_name)
# }


for(i in file_list){
  
  x <- read_csv(i)
  
  # sub nhgis for US
  i <- gsub("US", "nhgis", i)
  
  # Remove underscores from various parts of new_file_name depending on the length of string
  if(str_length(i) == 51){
    
    t <- str_split(i, "_")
    
    new_file_name <- paste0(t[[1]][1], "_", t[[1]][2], "_", t[[1]][3], t[[1]][4], "_", t[[1]][5], "_", t[[1]][6], t[[1]][7])
    
  } else{
    
    t <- str_split(i, "_")
    
    new_file_name <- paste0(t[[1]][1], "_", t[[1]][2], "_", t[[1]][3], t[[1]][4], "_", t[[1]][5], "_", t[[1]][6])
    
    
  }
  
  write_csv(x, new_file_name)
}
