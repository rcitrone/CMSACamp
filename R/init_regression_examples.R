# This file initializes the regression dataset examples

# NOTE: it is assumed that the current directory contains the data folder since
#       this repository was created using an R project

# ------------------------------------------------------------------------------

# Access tidyverse:
library(tidyverse)

# ------------------------------------------------------------------------------

# Need the following packages if not currently installed:
# install.packages("xml2")
# install.packages("rvest")

# Next create a dataset of NBA player statistics from basketball-reference.com,
# this will loop through several years of data (LeBron James era)

nba_player_stats <- map_dfr(c(2003:2019),
                            function(year) {
                              nba_url <- paste0("https://www.basketball-reference.com/leagues/NBA_",
                                                year, "_totals.html")
                              br_page <- xml2::read_html(nba_url)
                              
                              nba_year_player_stats <- rvest::html_table(br_page, fill = T)[[1]] %>%
                                # Remove the header rows where Player == "Player":
                                filter(Player != "Player",
                                       # As well as the rows corresponding to player totals across the teams
                                       # they played for in the 2019 season:
                                       Tm != "TOT") %>%
                                # Convert everything but Player, Pos, and Tm to numeric 
                                mutate_at(dplyr::vars(-Player, -Pos, -Tm), list(~as.numeric(.))) %>%
                                # Drop several columns not needed - so students calculate on their own the
                                # various efficiency metrics:
                                #dplyr::select(-Rk, -`FG%`, -`3P%`, -`2P%`, -`eFG%`, -`FT%`, -TRB, -PTS) %>%
                                # Rename the columns that were kept:
                                rename(player = Player, position = Pos, age = Age, team = Tm,
                                       games = G, games_started = GS, minutes_played = MP, 
                                       field_goals = FG, field_goal_attempts = FGA,
                                       three_pointers = `3P`, three_point_attempts = `3PA`,
                                       two_pointers = `2P`, two_point_attempts = `2PA`,
                                       free_throws = FT, free_throw_attempts = FTA,
                                       offensive_rebounds = ORB, defensive_rebounds = DRB,
                                       assists = AST, steals = STL, blocks = BLK, turnovers = TOV,
                                       personal_fouls = PF) %>%
                                mutate(season = year)
                            })

# Rename some columns and drop Rk:
nba_player_stats <- nba_player_stats %>%
  dplyr::select(-Rk) %>%
  rename(field_goal_perc = `FG%`,
         three_point_perc = `3P%`,
         two_point_perc = `2P%`,
         free_throw_perc = `FT%`,
         total_rebounds = TRB,
         total_points = PTS,
         effective_field_goal_perc = `eFG%`)

# Save this dataset:
write_csv(nba_player_stats, "data/regression_examples/nba_player_stats.csv")
