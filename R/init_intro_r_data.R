# This file initializes intro R datasets to be used in the first week of 
# CMSACamp. These should be relatively easy to work with and will be saved in
# the data/intro_r folder

# NOTE: it is assumed that the current directory contains the data folder since
#       this repository was created using an R project

# ------------------------------------------------------------------------------

# Load the Lahman package
# (install if you have not already)
# install.packages("Lahman")
library(Lahman)

# The Lahman library contains many different datasets, a good starting dataset
# that could be useful for demonstrating how to create new columns, group-by
# and summarize operations, and visualizations is the Teams dataset:
data("Teams")

# Load the tidyverse
# (install if you have not already)
# install.packages("tidyverse")
library(tidyverse)

# The follow code grabs just a subset of the variables from the Teams dataset:
mlb_teams_data <- Teams %>%
  # The first set of columns corresponds to meta-data about the team and season outcomes:
  dplyr::select(yearID, lgID, teamID, name, WSWin, Rank, G, W, L, 
                # Batting statistics:
                R, H, AB, BB, SO, HR, HBP, SF,
                # Pitching statistics
                RA, HA, BBA, SOA, HRA) %>%
  # Rename columns for ease:
  rename(year = yearID, league = lgID, team_id = teamID, team_name = name,
         win_world_series = WSWin, final_rank = Rank, 
         games_played = G, wins = W, losses = L,
         runs_scored = R, hits = H, at_bats = AB, walks = BB,
         strikeouts = SO, homeruns = HR, hit_by_pitch = HBP, sacrifice_flies = SF,
         runs_allowed = RA, hits_allowed = HA, walks_allowed = BBA, 
         strikeouts_against = SOA, homeruns_allowed = HRA)

# Save this dataset:
write_csv(mlb_teams_data, "data/intro_r/mlb_teams_data.csv")

# Using this dataset it is easy to compute several other statistics, these can
# be exercises for demonstrating how to create new columns:
# - batting_average = hits / at_bats
# - on_base_percentage = (hits + walks + hit_by_pitch) / (at_bats + walks + hit_by_pitch + sacrifice_flies)
# - homeruns_per_plate_appearance = homeruns / (at_bats + walks + hit_by_pitch + sacrifice_flies)
# - three_true_outcomes = strikeouts + walks + homeruns
# And of course ratios like:
# - strikeouts_to_walks = strikeouts / walks

# ------------------------------------------------------------------------------

# Next create a dataset of NBA player statistics from basketball-reference.com

# Need the following packages if not currently installed:
# install.packages("xml2")
# install.packages("rvest")

# The ballr package is kind of weird actually, so will just scrape the 2019 season 
# total statistics directly from the site using code adapted from the package:

nba_url <- "https://www.basketball-reference.com/leagues/NBA_2019_totals.html"
br_page <- xml2::read_html(nba_url)

nba_2019_player_stats <- rvest::html_table(br_page, fill = T)[[1]] %>%
  # Remove the header rows where Player == "Player":
  filter(Player != "Player") %>%
  # Convert everything but Player, Pos, and Tm to numeric 
  mutate_at(dplyr::vars(-Player, -Pos, -Tm), list(~as.numeric)) %>%
  # Drop several columns not needed - so students calculate on their own the
  # various efficiency metrics:
  dplyr::select(-Rk, -`FG%`, -`3P%`, -`2P%`, -`eFG%`, -`FT%`, -TRB, -PTS) %>%
  # Rename the columns that were kept:
  rename(player = Player, position = Pos, age = Age, team = Tm,
         games = G, games_started = GS, minutes_played = MP, 
         field_goals = FG, field_goal_attempts = FGA,
         three_pointers = `3P`, three_point_attempts = `3PA`,
         two_pointers = `2P`, two_point_attempts = `2PA`,
         free_throws = FT, free_throw_attempts = FTA,
         offensive_rebounds = ORB, defensive_rebounds = DRB,
         assists = AST, steals = STL, blocks = BLK, turnovers = TOV,
         personal_fouls = PF)

# Save this dataset:
write_csv(nba_2019_player_stats, "data/intro_r/nba_2019_player_stats.csv")

# Again can use this dataset to calculate percentages and stats like:
# - three_point_perc = three_pointers / three_point_attempts
# - field_goal_perc = field_goals / field_goal_attempts
# - free_throw_perc = free_throws / free_throw_attempts
# - total_points = 3 * three_pointers + 2 * two_pointers + free_throws
# And can calculate various ratios using these statistics as well.

# NOTE: this data is on the player-team level during the season, so if a player 
# switched teams in the middle of the season then they will have multiple rows.
# Makes for good practice for collapsing those rows together. 







