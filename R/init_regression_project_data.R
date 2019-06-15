# This file initializes the sports-reference dataset for the regression project

# NOTE: it is assumed that the current directory contains the data folder since
#       this repository was created using an R project

# ------------------------------------------------------------------------------

# Access tidyverse:
library(tidyverse)

# ------------------------------------------------------------------------------

# Need the following packages if not currently installed:
# install.packages("xml2")
# install.packages("rvest")
library(xml2)
library(rvest)

# Use the nbastatR package to get NBA stats going back to 2003:
library(nbastatR)

nba_stats_tables <- teams_players_stats(seasons = c(2004:2019), types = c("team"),
                    tables = c("general"), season_types = "Regular Season",
                    measures = "Base", modes = "Totals", defenses = "Overall",
                    is_plus_minus = F, is_pace_adjusted = F, periods = 0,
                    is_rank = F, game_segments = NA, divisions_against = NA,
                    conferences_against = NA, date_from = NA, date_to = NA,
                    last_n_games = 0, locations = NA, months = 0,
                    season_segments = NA, opponents = NA, countries = NA,
                    weights = NA, outcomes = NA, playoff_rounds = 0,
                    players_experience = NA, players_positions = NA, colleges = NA,
                    draft_picks = NA, draft_years = NA, game_scopes = NA,
                    heights = NA, shot_clock_ranges = NA,
                    clutch_times = "Last 5 Minutes", ahead_or_behind = "Ahead or Behind",
                    general_ranges = "Overall", dribble_ranges = "0 Dribbles",
                    shot_distance_ranges = "By Zone", touch_time_ranges = NA,
                    closest_defender_ranges = NA, point_diffs = 5, starters_bench = NA,
                    assign_to_environment = TRUE, add_mode_names = T,
                    return_message = TRUE)

# Next go through each of the different tables for each year, cleaning up some
# variable names and joining them together:
nba_team_season_summary <- map_dfr(1:nrow(nba_stats_tables),
                                   function(season_i) {
                                     season <- nba_stats_tables$slugSeason[season_i]
                                     season_data <- nba_stats_tables$dataTable[[season_i]] %>%
                                       # Drop unncessary columns:
                                       dplyr::select(-c(typeMeasure, isPlusMinus,
                                                        isPaceAdjust, isRank, idPlayoffRound,
                                                        idMonth, idTeamOpponent, idPeriod,
                                                        countLastNGames, contains("Rank"),
                                                        gp, pfd, idTeam, minutes)) %>%
                                       # Rename columns:
                                       rename(team = nameTeam,
                                              win_perc = pctWins,
                                              field_goals = fgm,
                                              field_goal_attemps = fga,
                                              field_goal_perc = pctFG,
                                              three_pointers = fg3m,
                                              three_point_attempts = fg3a,
                                              three_point_perc = pctFG3,
                                              two_pointers = fg2m,
                                              two_point_attempts = fg2a,
                                              two_point_perc = pctFG2,
                                              free_throws = ftm,
                                              free_throw_attemps = fta,
                                              free_throw_perc = pctFT,
                                              offensive_rebounds = oreb,
                                              defensive_rebounds = dreb,
                                              total_rebounds = treb,
                                              assists = ast,
                                              turnovers = tov,
                                              steals = stl,
                                              blocks = blk,
                                              blocks_against = blka,
                                              personal_fouls = pf,
                                              total_points = pts,
                                              score_differential = plusminus) %>%
                                       mutate(season = season)
                                     return(season_data)
                                   })

# Save this dataset:
write_csv(nba_team_season_summary, "data/regression_projects/nba_team_season_summary.csv")

# ------------------------------------------------------------------------------

# Hockey data was downloaded from https://evolving-hockey.com/

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
                            select(posteam, defteam, play_type, yards_gained, 
                                   air_yards, yards_after_catch, tackled_for_loss,
                                   fumble_lost, interception, qb_hit,
                                   sack, complete_pass, pass_touchdown, rush_touchdown,
                                   epa, pbp_season) %>%
                            # Deal with JAC and JAX problem:
                            mutate(posteam = ifelse(posteam == "JAC", "JAX", posteam),
                                   defteam = ifelse(defteam == "JAC", "JAX", defteam))
                        })

# Total offensive summaries:
nfl_total_offense_summary <-  nfl_pbp_data %>%
  filter(play_type %in% c("pass", "run")) %>%
  rename(team = posteam, season = pbp_season) %>%
  group_by(team, season) %>%
  summarize(off_total_yards_gained = sum(yards_gained, na.rm = TRUE),
            off_n_pass_touchdowns = sum(pass_touchdown, na.rm = TRUE),
            off_n_run_touchdowns = sum(rush_touchdown, na.rm = TRUE),
            off_n_touchdowns = off_n_pass_touchdowns + off_n_run_touchdowns,
            off_n_pass_or_run_plays = n(),
            off_n_sacks_allowed = sum(sack, na.rm = TRUE),
            off_n_qb_hits_allowed = sum(qb_hit, na.rm = TRUE),
            off_n_fumbles_lost = sum(fumble_lost, na.rm = TRUE),
            off_n_tackled_for_loss = sum(tackled_for_loss, na.rm = TRUE),
            off_n_interceptions_thrown = sum(interception, na.rm = TRUE)) 

# Total defensive summaries:
nfl_total_defense_summary <-  nfl_pbp_data %>%
  filter(play_type %in% c("pass", "run")) %>%
  rename(team = defteam, season = pbp_season) %>%
  group_by(team, season) %>%
  summarize(def_total_yards_allowed = sum(yards_gained, na.rm = TRUE),
            def_n_pass_touchdowns = sum(pass_touchdown, na.rm = TRUE),
            def_n_run_touchdowns = sum(rush_touchdown, na.rm = TRUE),
            def_n_touchdowns = def_n_pass_touchdowns + def_n_run_touchdowns,
            def_n_pass_or_run_plays = n(),
            def_n_sacks = sum(sack, na.rm = TRUE),
            def_n_qb_hits = sum(qb_hit, na.rm = TRUE),
            def_n_fumbles_forced = sum(fumble_lost, na.rm = TRUE),
            def_n_tackles_for_loss = sum(tackled_for_loss, na.rm = TRUE),
            def_n_interceptions = sum(interception, na.rm = TRUE)) 

# Now create an offensive summary by the play-type level
nfl_play_type_offense_summary <- nfl_pbp_data %>%
  group_by(posteam, pbp_season, play_type) %>%
  summarize(total_yards_gained = sum(yards_gained, na.rm = TRUE),
            n_plays = n(),
            completion_perc = mean(complete_pass, na.rm = TRUE)) %>%
  ungroup() %>%
  rename(team = posteam, season = pbp_season) %>%
  filter(play_type %in% c("pass", "run")) %>%
  gather("stat", "value", -team, -season, -play_type) %>%
  unite("play_type_stat", c("play_type", "stat")) %>%
  mutate(play_type_stat = paste0("off_", play_type_stat)) %>%
  spread(play_type_stat, value) %>%
  dplyr::select(-c(off_run_completion_perc))

# Do the same thing for defense:
nfl_play_type_defense_summary <- nfl_pbp_data %>%
  group_by(defteam, pbp_season, play_type) %>%
  summarize(total_yards_gained = sum(yards_gained, na.rm = TRUE),
            n_plays = n(),
            completion_perc = mean(complete_pass, na.rm = TRUE)) %>%
  ungroup() %>%
  rename(team = defteam, season = pbp_season) %>%
  filter(play_type %in% c("pass", "run")) %>%
  gather("stat", "value", -team, -season, -play_type) %>%
  unite("play_type_stat", c("play_type", "stat")) %>%
  mutate(play_type_stat = paste0("def_", play_type_stat)) %>%
  spread(play_type_stat, value) %>%
  dplyr::select(-c(def_run_completion_perc))

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
  inner_join(nfl_total_offense_summary, by = c("team", "season")) %>%
  inner_join(nfl_total_defense_summary, by = c("team", "season")) %>%
  inner_join(nfl_play_type_offense_summary, by = c("team", "season")) %>%
  inner_join(nfl_play_type_defense_summary, by = c("team", "season"))

team_season_summary <- team_season_summary %>%
  mutate(score_differential = points_scored - points_allowed)

# Load the nflteams dataset from nflscrapR:
library(nflscrapR)
data("nflteams")

# Join the division:
team_season_summary <- team_season_summary %>%
  left_join(select(nflteams, abbr, division), by = c("team" = "abbr"))

# And save:
write_csv(team_season_summary, 
          "data/regression_projects/nfl_team_season_summary.csv")



