# This file initializes some example datasets with x,y coordinates to use for
# generating heatmaps and plots with hexagons. These datasets can then also
# be used for examples with density estimation, clustering, and additive models.
# All datasets will be saved in the data/xy_examples folder.

# NOTE: it is assumed that the current directory contains the data folder since
#       this repository was created using an R project

# ------------------------------------------------------------------------------

# First will create a dataset of batted ball locations hit in 2018 by NL MVP Christian Yelich

# We will use the 'baseballr' package created by Bill Petti to get this data:
# install.packages("devtools")
# devtools::install_github("BillPetti/baseballr")
library(baseballr)

playerid_lookup(last_name = "Yelich")
# Use 592885

# Pull all of Yelich's Statcast data in 2018:
yelich_statcast_data <- scrape_statcast_savant_batter(start_date = "2018-01-01", 
                                                      end_date = "2018-12-31", 
                                                      batterid = 592885)

library(tidyverse)
# Get all the batted balls, only a subset of columns:
yelich_batted_balls <- yelich_statcast_data %>%
  filter(type == "X") %>%
  # Now extract just a subset of columns that will be used for generate 
  # some plots of the x,y locations:
  select(pitch_type, bb_type, hc_x, hc_y, launch_speed, launch_angle, events) %>%
  # Fix the batted ball coordinates for plotting
  mutate(hc_x = hc_x - 125.42, 
         hc_y = 198.27 - hc_y) %>%
  rename(hit_x = hc_x,
         hit_y = hc_y,
         exit_velocity = launch_speed,
         batted_ball_type = bb_type,
         outcome = events)

# Save this dataset:
write_csv(yelich_batted_balls, "data/xy_examples/yelich_2018_batted_balls.csv")

# ------------------------------------------------------------------------------

# Next, use the baseballr package to get all pitches thrown by NL Cy Young Jacob deGrom
playerid_lookup(last_name = "deGrom")
# Use 594798 

# Pull all of deGrom's Statcast data in 2018:
degrom_statcast_data <- scrape_statcast_savant_pitcher(start_date = "2018-01-01", 
                                                      end_date = "2018-12-31", 
                                                      pitcherid = 594798)

# Now only use a subset of the columns relevant to the pitch level information:
degrom_pitches <- degrom_statcast_data %>%
  select(pitch_type, release_speed, release_spin_rate, 
         plate_x, plate_z, type, balls, strikes, events)
# Save this dataset:
write_csv(degrom_pitches, "data/xy_examples/degrom_2018_pitches.csv")

# ------------------------------------------------------------------------------

# Next, grab NBA shot location data for Steph Curry using the 'nbastatR' package:
# devtools::install_github("abresler/nbastatR")
library(nbastatR)

# Get shots for Warriors in current NBA season:
gsw_shots <- teams_shots(teams = "Golden State Warriors", 
                         seasons = c(2019))

# Now only use Steph Curry's shot location data, grabbing the isShotMade variable
steph_curry_shots <- gsw_shots %>%
  filter(idPlayer == 201939) %>%
  # Only grab the necessary columns:
  select(locationX, locationY, distanceShot, isShotMade, numberPeriod, typeShot) %>%
  rename(shot_x = locationX, shot_y = locationY,
         shot_distance = distanceShot, 
         is_shot_made = isShotMade,
         period = numberPeriod,
         shot_type = typeShot)

# Save this dataset:
write_csv(degrom_pitches, "data/xy_examples/degrom_2018_pitches.csv")

