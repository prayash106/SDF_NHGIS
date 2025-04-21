## Compute environmental summaries for downloaded shapefiles
## 
## This script loads in shapefiles and land cover raster datasets,
## computes land cover fractions, and writes out files to disk.
## 

library(exactextractr)
library(terra)
library(sf)
library(ipumsr)
library(tidyverse)

options(scipen = 999)

## ---- Constants ----
# File path to nlcd data
nlcd_path <- "/pkg/popgis/labpcs/data_projects/environmental_summaries/NLCD/"

# Non-contiguous US states and territories
not_cont_US <- c("02", "15", "72")

shps <- c("us_tract_2020_tl2020", "us_tract_2010_tl2020", "us_county_2020_tl2020",
          "us_tract_2022_tl2022", "us_county_2022_tl2022", "us_cty_sub_2020_tl2020", "us_cty_sub_2010_tl2020",
          "us_cty_sub_2022_tl2022", "us_place_2020_tl2020", "us_place_2010_tl2020", "us_place_2022_tl2022")

shps <- c("us_cty_sub_2020_tl2020", "us_cty_sub_2010_tl2020", "us_cty_sub_2022_tl2022")


## ---- Load the NLCD files setting NLCD as working directory ----
NLCD_2021 <- rast(paste0(nlcd_path, "nlcd_2021_land_cover_l48_20230630.img"))
NLCD_2019 <- rast(paste0(nlcd_path, "nlcd_2019_land_cover_l48_20210604.img"))
NLCD_2016 <- rast(paste0(nlcd_path, "nlcd_2016_land_cover_l48_20210604.img"))
NLCD_2013 <- rast(paste0(nlcd_path, "nlcd_2013_land_cover_l48_20210604.img"))
NLCD_2011 <- rast(paste0(nlcd_path, "nlcd_2011_land_cover_l48_20210604.img"))
NLCD_2008 <- rast(paste0(nlcd_path, "nlcd_2008_land_cover_l48_20210604.img"))
NLCD_2006 <- rast(paste0(nlcd_path, "nlcd_2006_land_cover_l48_20210604.img"))
NLCD_2004 <- rast(paste0(nlcd_path, "nlcd_2004_land_cover_l48_20210604.img"))
NLCD_2001 <- rast(paste0(nlcd_path, "nlcd_2001_land_cover_l48_20210604.img"))

## ---- Create a function to loop over shps
compute_nlcd_summaries <- function(shp_name){
  ## ---- Load a shapefile ----
  i <- shp_name
  j <- str_sub(i, 1, (str_length(i) - 7))
  j_year <- str_sub(j, -4)
  shp <- read_ipums_sf("data/input/nhgis2050_shape.zip", file_select = contains(j))
  
  # Remove AK, HI, PR from the shapefile
  if(j_year != "2010"){
    shp <- shp |> 
      filter(!STATEFP %in% not_cont_US)
  } else {
    shp <- shp |> 
      filter(!STATEFP10 %in% not_cont_US)
  }
  
  # Transform to Albers Equal Area projection to match the NLCD CRS
  shp <- st_transform(shp, crs(NLCD_2021))
  
  ## ---- Function to calculate land cover fractions for each shp and year ----
  calculate_fractions <- function(shp_data, NLCD_data, year, geog_year) {
    # Extract fractions for each land cover class
    fractions <- exact_extract(NLCD_data, shp_data$geometry, "frac")
    
    # Add GISJOIN column from tract_shp_data to fractions
    fractions$GISJOIN <- shp_data$GISJOIN
    
    # Add a column GEOGYEAR that specifies the source year of geographical shape file
    fractions$GEOGYEAR <- geog_year
    
    # Add a column NLCDYEAR that specifies the year of NLCD data
    fractions$NLCDYEAR <- year
    
    # Shift the GISJOIN, GEOGYEAR, and NLCDYEAR columns to the front
    fractions <- fractions %>%
      select(GISJOIN, GEOGYEAR, NLCDYEAR, everything())
    
    # Select the first three column names (GISJOIN, GEOGYEAR, NLCDYEAR) without changing them
    unchanged_columns <- names(fractions)[1:3]
    
    # Select all column names from 4 to (ncol(df)) and append the year
    changed_columns <- paste0(names(fractions)[4:ncol(fractions)])
    
    # Substitute PROP for frac in changed_columns 
    changed_columns <- gsub("frac", "PROP", changed_columns)
    
    # Combine unchanged and changed columns
    new_column_names <- c(unchanged_columns, changed_columns)
    
    # Assign new column names to the dataframe
    colnames(fractions) <- new_column_names
    
    return(fractions)
  }
  
  # Geog unit fraction for each NLCD
  fractions_2021 <- calculate_fractions(shp, NLCD_2021, "2021", j_year)
  fractions_2019 <- calculate_fractions(shp, NLCD_2019, "2019", j_year)
  fractions_2016 <- calculate_fractions(shp, NLCD_2016, "2016", j_year)
  fractions_2013 <- calculate_fractions(shp, NLCD_2013, "2013", j_year)
  fractions_2011 <- calculate_fractions(shp, NLCD_2011, "2011", j_year)
  fractions_2008 <- calculate_fractions(shp, NLCD_2008, "2008", j_year)
  fractions_2006 <- calculate_fractions(shp, NLCD_2006, "2006", j_year)
  fractions_2004 <- calculate_fractions(shp, NLCD_2004, "2004", j_year)
  fractions_2001 <- calculate_fractions(shp, NLCD_2001, "2001", j_year)
  
  # Write out the nlcd-year specific files to CSVs 
  # List of fractions dataframes and their corresponding years
  fractions_list <- list(
    "2021" = fractions_2021,
    "2019" = fractions_2019,
    "2016" = fractions_2016,
    "2013" = fractions_2013,
    "2011" = fractions_2011,
    "2008" = fractions_2008,
    "2006" = fractions_2006,
    "2004" = fractions_2004,
    "2001" = fractions_2001
  )
  
  ## ---- Write out data to CSVs ----
  # Save each single NLCD-year fraction to a CSV file
  for (year in names(fractions_list)) {
    write_csv(fractions_list[[year]], paste0("data/output/", gsub("us", "US", i), "_nlcd_", year, ".csv"))
  }
  
  ## ---- Create time varies by column data frame ----
  # Function to rename columns by adding _year to the end, except GISJOIN, GEOGYEAR, and NLCDYEAR
  rename_columns <- function(df, year) {
    # Select the first three column names (GISJOIN, GEOGYEAR, NLCDYEAR) without changing them
    unchanged_columns <- names(df)[1:3]
    
    # Select all column names from 4 to (ncol(df)) and append the year
    changed_columns <- paste0(names(df)[4:ncol(df)], "_", year)
    
    # Substitute PROP for frac in changed_columns 
    # changed_columns <- gsub("frac", "PROP", changed_columns)
    
    # Combine unchanged and changed columns
    new_column_names <- c(unchanged_columns, changed_columns)
    
    # Assign new column names to the dataframe
    colnames(df) <- new_column_names
    
    return(df)
  }
  
  fractions_2021_renamed <- rename_columns(fractions_2021, "2021")
  fractions_2019_renamed <- rename_columns(fractions_2019, "2019")
  fractions_2016_renamed <- rename_columns(fractions_2016, "2016")
  fractions_2013_renamed <- rename_columns(fractions_2013, "2013")
  fractions_2011_renamed <- rename_columns(fractions_2011, "2011")
  fractions_2008_renamed <- rename_columns(fractions_2008, "2008")
  fractions_2006_renamed <- rename_columns(fractions_2006, "2006")
  fractions_2004_renamed <- rename_columns(fractions_2004, "2004")
  fractions_2001_renamed <- rename_columns(fractions_2001, "2001")
  
  # List of renamed census tract fractions dataframes
  fractions_renamed_list <- list(
    fractions_2021_renamed,
    fractions_2019_renamed,
    fractions_2016_renamed,
    fractions_2013_renamed,
    fractions_2011_renamed,
    fractions_2008_renamed,
    fractions_2006_renamed,
    fractions_2004_renamed,
    fractions_2001_renamed
  )
  
  # Remove the NLCDYEAR column from each dataframe in the list and remove GEOGYEAR from all but the first dataframe
  fractions_renamed_list <- lapply(fractions_renamed_list, function(df) {
    df %>% select(-matches("^NLCDYEAR"))
  })
  
  fractions_renamed_list <- map2(fractions_renamed_list, seq_along(fractions_renamed_list), function(df, i) {
    if (i > 1) {
      df %>% select(-GEOGYEAR)
    } else {
      df
    }
  })
  
  # Merge all census tract fractions dataframes based on the GISJOIN column
  merged_data <- reduce(fractions_renamed_list, left_join, by = "GISJOIN")
  
  # Reorder columns to move GEOGYEAR right after GISJOIN
  merged_data <- merged_data %>%
    select(GISJOIN, GEOGYEAR, everything())
  
  # Write out to a CSV file 
  write_csv(merged_data, paste0("data/output/", gsub("us", "US", i), "_nlcd", ".csv"))
  
}

map(shps, ~ compute_nlcd_summaries(.x))

