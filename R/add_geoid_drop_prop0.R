## Add GEOIDs to environmental summary CSVs and drop PROP_0 from
## files.

library(tidyverse)

options(scipen = 999)

## ---- Constants ----
output_dir <- "data/output"

## ---- List files in output_dir ----
file_list <- list.files(output_dir, pattern = "cty_sub", full.names = TRUE)

## test cases
## 1, 10, 31, 40, 61, 70, 91, 100
#file_list <- file_list[c(1, 10, 31, 40, 61, 70, 91, 100)]
## ---- Add GEOID and drop PROP_0 ----
for(i in file_list){
  
  x <- read_csv(i)
  
  if(str_detect(i, "county")){
    
    if(str_length(i) == 47){
      
      x <- x |> 
        select(-PROP_0) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 7))) |> 
        select(GISJOIN, GEOID, everything())
      
    } else {
      
      x <- x |> 
        select(-contains("PROP_0")) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 7))) |> 
        select(GISJOIN, GEOID, everything()) |> 
        pivot_longer(cols = (PROP_11_2021:PROP_95_2001), names_to = "var", values_to = "prop") |> 
        arrange(GISJOIN, var) |> 
        pivot_wider(names_from = var, values_from = prop)
      
    }
    
  }else if(str_detect(i, "tract")){
    
    if(str_length(i) == 46){
      
      x <- x |> 
        select(-PROP_0) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 7), str_sub(GISJOIN, 9, 14))) |> 
        select(GISJOIN, GEOID, everything())
      
    } else {
      
      x <- x |> 
        select(-contains("PROP_0")) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 7), str_sub(GISJOIN, 9, 14))) |> 
        select(GISJOIN, GEOID, everything()) |> 
        pivot_longer(cols = (PROP_11_2021:PROP_95_2001), names_to = "var", values_to = "prop") |> 
        arrange(GISJOIN, var) |> 
        pivot_wider(names_from = var, values_from = prop)
               
    }
    
  } else if(str_detect(i, "place")){

    if(str_length(i) == 46){
      
      x <- x |> 
        select(-PROP_0) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 9))) |> 
        select(GISJOIN, GEOID, everything())
      
    } else {
      
      x <- x |> 
        select(-contains("PROP_0")) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 9))) |> 
        select(GISJOIN, GEOID, everything()) |> 
        pivot_longer(cols = (PROP_11_2021:PROP_95_2001), names_to = "var", values_to = "prop") |> 
        arrange(GISJOIN, var) |> 
        pivot_wider(names_from = var, values_from = prop)
    }
               
  } else {
    
    if(str_length(i) == 48){
      
      x <- x |> 
        select(-PROP_0) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 7), str_sub(GISJOIN, 9, 13))) |> 
        select(GISJOIN, GEOID, everything())
      
    } else {
      
      x <- x |> 
        select(-contains("PROP_0")) |> 
        mutate(GEOID = paste0(str_sub(GISJOIN, 2, 3), str_sub(GISJOIN, 5, 7), str_sub(GISJOIN, 9, 13))) |> 
        select(GISJOIN, GEOID, everything()) |> 
        pivot_longer(cols = (PROP_11_2021:PROP_95_2001), names_to = "var", values_to = "prop") |> 
        arrange(GISJOIN, var) |> 
        pivot_wider(names_from = var, values_from = prop)
      
    }
  }
  
  write_csv(x, i)
}
