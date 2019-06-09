# This file initializes the EDA project data. 

# NOTE: it is assumed that the current directory contains the data folder since
#       this repository was created using an R project

# ------------------------------------------------------------------------------

# Access tidyverse:
library(tidyverse)

# ------------------------------------------------------------------------------

# First will create a dataset of batted ball locations hit by the top five players
# according to fangraphs offense runs created as of 12PM on 6/9/19 in the 2019 season:
# (1) Mike Trout, (2) Christian Yelich, (3) Cody Bellinger, (4) Josh Bell, (5) Joey Gallo

# We will use the 'baseballr' package created by Bill Petti to get this data:
# install.packages("devtools")
# devtools::install_github("BillPetti/baseballr")
library(baseballr)

# Find the player ids:
playerid_lookup(last_name = "Trout", first_name = "Mike")
# Use 545361
playerid_lookup(last_name = "Yelich", first_name = "Christian")
# Use 592885
playerid_lookup(last_name = "Bellinger", first_name = "Cody")
# Use 641355
playerid_lookup(last_name = "Bell", first_name = "Josh")
# Use 605137
playerid_lookup(last_name = "Gallo", first_name = "Joey")
# Use 608336

# Pull all of Yelich's Statcast data in 2018:
yelich_statcast_data <- scrape_statcast_savant_batter(start_date = "2018-01-01", 
                                                      end_date = "2018-12-31", 
                                                      batterid = 592885)
# Remove the chadwick lookup table from global environment:
rm(chadwick_player_lu_table)

# Loop through each player_id, stacking together a dataframe of their batted 
# ball locations:
top_batters <- c("trout" = 545361, "yelich" = 592885, "bellinger" = 641355,
                 "bell" = 605137, "gallo" = 608336)
top_batters_batted_ball_data <- map_dfr(1:length(top_batters),
                                        function(batter_i) {
                                          scrape_statcast_savant_batter(start_date = "2019-01-01", 
                                                                        end_date = "2019-06-09", 
                                                                        batterid = top_batters[batter_i]) %>%
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
                                                   outcome = events) %>%
                                            # Create a player column with their name:
                                            mutate(player = names(top_batters)[batter_i])
                                        })

# Save this dataset:
write_csv(top_batters_batted_ball_data, 
          "data/eda_projects/top_hitters_2019_batted_balls.csv")

# ------------------------------------------------------------------------------

# Use reticulate and the py_ball python package to scrape WNBA shot locations,
# NOTE THE FOLLOWING CODE IS USED TO ENSURE THE CORRECT VERSION OF PYTHON IS
# LOADED CONTAINING THE py_ball PACKAGE:
Sys.setenv(RETICULATE_PYTHON = "/Users/ron/anaconda3/bin/python")
library(reticulate)
# Source the python script for getting game data:
source_python("python/get_wnba_shots.py")

# Now get the shot data for the latest Connecticut Sun game against the Los Angeles Sparks:
latest_game_events <- read_game_shots('1021900021')

# This dataset contains all events in the game, so let's only grab some columns
# of interest and rename them, we want the shots, rebounds, turnovers, and fouls with
# additional information based on the example here: https://github.com/basketballrelativity/location_data/blob/master/wnba_location_charts.ipynb

# First determine the period:
period_start_evt <- latest_game_events$evt[which(latest_game_events$de == "Start Period")]

latest_game_data <- latest_game_events %>%
  # Create a column denoting the period in the game:
  mutate(period = sapply(evt, function(event_i) ifelse(event_i %in% period_start_evt,
                                                       which(period_start_evt == event_i),
                                                       NA))) %>%
  fill(period) %>%
  # Now only want the shots, rebounds, turnovers, and fouls:
  filter(etype %in% c(1:6)) %>%
  # Now create a column denoting the event:
  mutate(event = case_when(etype %in% c(1, 2) ~ "field_goal_attempt",
                           etype == 3 ~ "free_throw_attempt",
                           etype == 4 ~ "rebound",
                           etype == 5 ~ "turnover",
                           TRUE ~ "foul"),
         # Next create is_shot_made column for both regular shot_attempt and free_throw:
         shot_made = ifelse(etype == 2 | (etype == 3 & !str_detect(de, "Missed")),
                               1, 0),
                                  # etype == 1 ~ 0,
                                  # etype == 3 & str_detect(de, "Missed") ~ 0,
                                  # etype == 3 & !str_detect(de, "Missed") ~ 1,
                                  # TRUE ~ 0),
         # Indicator if it was an assisted shot:
         assisted = ifelse(etype == 1 & !is.na(epid), 1, 0),
         # Indicator if it was a shooting foul:
         shooting_foul = ifelse(etype == 6 & mtype == 2, 1, 0),
         # Field goal type:
         field_goal_type = case_when(event == "field_goal_attempt" & 
                                       str_detect(de, "3pt Shot") ~ "three_pointer",
                                     event == "field_goal_attempt" &
                                       !str_detect(de, "3pt Shot") ~ "two_pointer",
                                     TRUE ~ NA_character_),
         # Now extract the team - based on the first 3 capital letter sequence:
         team = tolower(str_extract(de, "[:upper:]{3}"))) %>%
  # Now rename some columns:
  rename(description = de, con_score = hs, las_score = vs,
         clock = cl, x_loc = locX, y_loc = locY) %>%
  # Get in a desired order:
  select(period, clock, las_score, con_score, description, team, event, 
         x_loc, y_loc, field_goal_type, shot_made, assisted, shooting_foul) %>%
  # Just going to drow the free throw attempts for now since the locations are 
  # recorded differently, and as it turns out rebounds are coded really odd:
  filter(!(event %in% c("free_throw_attempt", "rebound"))) %>%
  # Now compute shot distance in feet:
  mutate(distance_from_hoop = sqrt((x_loc / 10)^2 + (y_loc / 10)^2))

# Save this dataset:
write_csv(latest_game_data, 
          "data/eda_projects/wnba_sparks_sun_game.csv")

# ------------------------------------------------------------------------------

# Now create an historical dataset of NFL team performance using nflscrapR data

# Join together the regular season play-by-play data including a column to 
# denote the season from 2009 to 2018:
nfl_pbp_data <- map_dfr(c(2009:2018),
                    function(x) {
                      read_csv(paste0("https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/play_by_play_data/regular_season/reg_pbp_",
                                      x, ".csv")) %>%
                        mutate(pbp_season = x) %>%
                        # Only need the posteam, defteam, play_type, yards_gained, and epa:
                        select(posteam, defteam, play_type, yards_gained, epa, pbp_season) %>%
                        # Deal with JAC and JAX problem:
                        mutate(posteam = ifelse(posteam == "JAC", "JAX", posteam),
                               defteam = ifelse(defteam == "JAC", "JAX", defteam))
                    })

# Now create an offensive summary:
nfl_offense_summary <- nfl_pbp_data %>%
  group_by(posteam, pbp_season, play_type) %>%
  summarize(off_total_yards_gained = sum(yards_gained, na.rm = TRUE),
            off_yards_gained_per_att = mean(yards_gained, na.rm = TRUE),
            off_total_epa = sum(epa, na.rm = TRUE),
            off_epa_per_att = mean(epa, na.rm = TRUE)) %>%
  ungroup() %>%
  rename(team = posteam, season = pbp_season) %>%
  filter(play_type %in% c("pass", "run")) %>%
  gather("stat", "value", -team, -season, -play_type) %>%
  unite("play_type_stat", c("play_type", "stat")) %>%
  spread(play_type_stat, value)

# Do the same thing for defense:
nfl_defense_summary <- nfl_pbp_data %>%
  group_by(defteam, pbp_season, play_type) %>%
  summarize(def_total_yards_allowed = sum(yards_gained, na.rm = TRUE),
            def_yards_allowed_per_att = mean(yards_gained, na.rm = TRUE),
            def_total_epa = sum(epa, na.rm = TRUE),
            def_epa_per_att = mean(epa, na.rm = TRUE)) %>%
  ungroup() %>%
  rename(team = defteam, season = pbp_season) %>%
  filter(play_type %in% c("pass", "run")) %>%
  gather("stat", "value", -team, -season, -play_type) %>%
  unite("play_type_stat", c("play_type", "stat")) %>%
  spread(play_type_stat, value)

# Now the season summaries:
nfl_games_data <- map_dfr(c(2009:2018),
                        function(x) {
                          read_csv(paste0("https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/games_data/regular_season/reg_games_",
                                          x, ".csv")) %>%
                            # Only need the posteam, defteam, play_type, yards_gained, and epa:
                            select(home_team, away_team, season, home_score, away_score, game_id) %>%
                            # Deal with JAC and JAX problem:
                            mutate(home_team = ifelse(home_team == "JAC", "JAX", home_team),
                                   away_team = ifelse(away_team == "JAC", "JAX", away_team))
                        }) %>%
  # Create a column, Winner for the games_data, that allows for tied games,
  # as well as score differential columns for both home and away:
  mutate(winner = ifelse(home_score > away_score,
                         home_team, 
                         ifelse(home_score < away_score,
                                away_team, "tie")))

# For each team, compute their number of wins, losses, points_scored, points_allowed
# in each season by breaking them up by home and away games:

team_season_summary <- map_dfr(unique(nfl_games_data$home_team),
                               function(nfl_team) {
                                 # First get home game summaries:
                                 home_game_summary <- nfl_games_data %>%
                                   filter(home_team == nfl_team) %>%
                                   rename(points_scored = home_score,
                                          points_allowed = away_score) %>%
                                   mutate(won = ifelse(home_team == winner, 1, 0),
                                          lost = ifelse(away_team == winner, 1, 0),
                                          tied = ifelse(winner == "tie", 1, 0)) %>%
                                   rename(team = home_team) %>%
                                   select(team, season, points_scored, 
                                          points_allowed, won, lost, tied) %>%
                                   group_by(team, season) %>%
                                   summarize(points_scored = sum(points_scored, na.rm = TRUE),
                                             points_allowed = sum(points_allowed, na.rm = TRUE),
                                             wins = sum(won, na.rm = TRUE),
                                             losses = sum(lost, na.rm = TRUE),
                                             ties = sum(tied, na.rm = TRUE)) %>%
                                   ungroup()
                                 
                                 # Now the away game:
                                 away_game_summary <- nfl_games_data %>%
                                   filter(away_team == nfl_team) %>%
                                   rename(points_scored = away_score,
                                          points_allowed = home_score) %>%
                                   mutate(won = ifelse(away_team == winner, 1, 0),
                                          lost = ifelse(home_team == winner, 1, 0),
                                          tied = ifelse(winner == "tie", 1, 0)) %>%
                                   rename(team = away_team) %>%
                                   select(team, season, points_scored, 
                                          points_allowed, won, lost, tied) %>%
                                   group_by(team, season) %>%
                                   summarize(points_scored = sum(points_scored, na.rm = TRUE),
                                             points_allowed = sum(points_allowed, na.rm = TRUE),
                                             wins = sum(won, na.rm = TRUE),
                                             losses = sum(lost, na.rm = TRUE),
                                             ties = sum(tied, na.rm = TRUE)) %>%
                                   ungroup()
                                 
                                 # Now stack them together and compute the 
                                 # summaries again:
                                 home_game_summary %>%
                                   bind_rows(away_game_summary) %>%
                                   group_by(team, season) %>%
                                   summarize(points_scored = sum(points_scored, na.rm = TRUE),
                                             points_allowed = sum(points_allowed, na.rm = TRUE),
                                             wins = sum(wins, na.rm = TRUE),
                                             losses = sum(losses, na.rm = TRUE),
                                             ties = sum(ties, na.rm = TRUE))
                               })

# Now join the offense and defense numbers:
team_season_summary <- team_season_summary %>%
  inner_join(nfl_offense_summary, by = c("team", "season")) %>%
  inner_join(nfl_defense_summary, by = c("team", "season"))


# Load the nflteams dataset from nflscrapR:
library(nflscrapR)
data("nflteams")

# Join the division:
team_season_summary <- team_season_summary %>%
  left_join(select(nflteams, abbr, division), by = c("team" = "abbr"))

# And save:
write_csv(team_season_summary, 
          "data/eda_projects/nfl_teams_season_summary.csv")

