## Download required shapefiles for environmental summaries
## 
## This script specifies the shapefiles for which we want to create 
## environmental summaries. It uses the ipumsr package to create, submit,
## and download required shapefiles.

require(ipumsr)
require(here)

## ---- Specify the shapefiles we want to download ----
# 1. Create vector of shapefiles to download
shps <- c("us_tract_2020_tl2020", "us_tract_2010_tl2020", "us_county_2020_tl2020", "us_county_2010_tl2020",
          "us_tract_2022_tl2022", "us_county_2022_tl2022", "us_cty_sub_2020_tl2020", "us_cty_sub_2010_tl2020",
          "us_cty_sub_2022_tl2022", "us_place_2020_tl2020", "us_place_2010_tl2010", "us_place_2022_tl2022",
          "us_cbsa_2020_tl2020", "us_cbsa_2022_tl2021")

# 2. Define extract request
extract <- define_extract_nhgis(
  description = "environmental summaries, October 2024",
  shapefiles = shps
)

# 3. Submit the extract to NHGIS
submitted_extract <- submit_extract(extract)

# 4. Wait for the extract to be finished
downloadable_extract <- wait_for_extract(submitted_extract)

# 5. Download it to a local folder in the topic directory
download_extract(downloadable_extract, here::here("data", "input"))
