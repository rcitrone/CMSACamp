# Intro data overview

This folder contains the intro datasets generated via the [`init_intro_r_data.R`](https://github.com/ryurko/CMSACamp/blob/master/R/init_intro_r_data.R)
script. The two files so far are:

* [mlb_teams_data.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/intro_r/mlb_teams_data.csv?token=AFKSV7BGJHKW3W72AMN2K5C453U7Q) - team data for each season going back to 1871, courtesy of the [`Lahman` package](https://cran.r-project.org/web/packages/Lahman/index.html),
* [nba_2019_player_stats.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/intro_r/nba_2019_player_stats.csv?token=AFKSV7EZOGYYTLAWNZ7YRPC453VNQ) - player statistics from the 2019 NBA season, courtesy of [basketball-reference](https://www.basketball-reference.com/leagues/NBA_2019_totals.html).

Both of these datasets have variables necessary for generating a variety of plots,
as well as demonstrating how to perfrom the basic split-apply-combine operations.

# MLB teams data

Each row in the [mlb_teams_data.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/intro_r/mlb_teams_data.csv?token=AFKSV7BGJHKW3W72AMN2K5C453U7Q) dataset corresponds to a single team in a single
season. The column names are self-explanatory, organized below by the type of
information they contain:

* meta - `year`, `league`, `team_id`, `team_name`,
* season outcome - `win_world_series`, `final_rank`, `games_played`, `wins`, `losses`,
* offensive stats - `runs_scored`, `hits`, `losses`, `runs_scored`, `hits`, `at_bats`, `walks`, `strikeouts`, `homeruns`, `hit_by_pitch`, `sacrifice_flies`
* defensive stats - `runs_allowed`, `hits_allowed`, `walks_allowed`, `strikeouts_against`, `homeruns_allowed`

Using this dataset, one can easily have students calculate various other types
of statistics to practice `R` operations like:

* `batting_average` = `hits` / `at_bats`
* `on_base_percentage` = (`hits` + `walks` + `hit_by_pitch`) / (`at_bats` + `walks` + `hit_by_pitch` + `sacrifice_flies`)
* `homeruns_per_plate_appearance` = `homeruns` / (`at_bats` + `walks` + `hit_by_pitch` + `sacrifice_flies`)
* `three_true_outcomes` = `strikeouts` + `walks` + `homeruns`
* `strikeouts_to_walks` = `strikeouts` / `walks`

# NBA 2019 player stats

Each row in the [nba_2019_player_stats.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/intro_r/nba_2019_player_stats.csv?token=AFKSV7EZOGYYTLAWNZ7YRPC453VNQ) dataset corresponds to a single player
with a single team during the 2019 season. Since players can switch teams during
the course of the season, this means a single player can have more than one row,
e.g. Nikola Mirotic has two rows since he played for NOP and MIL this season. 
All of the column names are self-explanatory, corresponding to the player's 2019
statistics.

Again one can use this dataset to calculate percentages and stats like:
* `three_point_perc` = `three_pointers` / `three_point_attempts`
* `field_goal_perc` = `field_goals` / `field_goal_attempts`
* `free_throw_perc` = `free_throws` / `free_throw_attempts`
* `total_points` = 3 x `three_pointers` + 2 x `two_pointers` + `free_throws`



