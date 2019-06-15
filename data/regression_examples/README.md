# Regression datasets overview

This folder contains the regression dataset generated via the [`init_regression_examples.R`](https://github.com/ryurko/CMSACamp/blob/master/R/init_regression_examples.R)
script. The one file so far is:

* [nba_player_stats.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_examples/nba_player_stats.csv) - player statistics for 2003 to 2019 NBA seasons, courtesy of [basketball-reference](https://www.basketball-reference.com/leagues/NBA_2019_totals.html).

# NBA player stats

Each row in the [nba_player_stats.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_examples/nba_player_stats.csv) dataset corresponds to a single player with a single team during a single season, dating back to 2003 (the start of the LeBron James era). Since players can switch teams during the course of the season, this means a single player can have more than one row, e.g. Nikola Mirotic has two rows for 2019 since he played for NOP and MIL this season. 
All of the column names are self-explanatory, corresponding to the player's statistics,
for a particular year (denoted by the `season` column). Note that the columns
ending with `*_perc* mean the percentage based statistics, and that `effective_field_goal_perc`
is the [effective field goal percentage](https://www.washingtonpost.com/what-is-effective-field-goal-percentage/a7e174de-5c62-4c9d-a687-01457731c1c2_note.html?noredirect=on&utm_term=.025575072d71) `= (field_goals + 0.5 * three_pointers) / field_goal_attempts`.

