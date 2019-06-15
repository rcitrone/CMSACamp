# EDA projects data overview

There are four different datasets for the EDA projects (three of which were generated via the [`init_regression_project_data.R`](https://github.com/ryurko/CMSACamp/blob/master/R/init_regression_project_data.R) script):

* [nfl_team_season_summary.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_projects/nfl_teams_season_summary.csv) - summary of regular season performance for each NFL team since 2009, data accessed via [`nflscrapR`](https://github.com/maksimhorowitz/nflscrapR),
* [nba_team_season_summary.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_projects/nba_team_season_summary.csv) - summary of regular season performance for each NBA team since 2003, courtesy of [NBA stats](https://stats.nba.com/) via the ['nbastatR package'](http://asbcllc.com/nbastatR/index.html),
* [nhl_team_season_summary.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_projects/nhl_team_season_summary.csv) - summary of regular season performance for each NHL team since 2007, courtesy of [Evolving-Hockey](https://evolving-hockey.com/),
* [tennis_2013_2017_GS.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/eda_projects/tennis_2013_2017_GS.csv) - tennis grand slam statistics for 3066 ATP and WTA matches between 2013 and 2017.  Data from Jeff Sackman's [tennis data repo](https://github.com/JeffSackmann), retreived by Stephanie Kovalchik's [`R deuce` package](https://github.com/skoval/deuce/blob/master/DESCRIPTION), and synthethesized in Gallagher, Frisoli, and Luby's [`R courtsports` package](https://github.com/shannong19/courtsports).

# NFL team season summary data

Each row in the [nfl_team_season_summary.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_projects/nfl_team_season_summary.csv) dataset corresponds to a single NFL team in a single
regular season. The column names are organized below by the type of information they contain, with
the first set of columns being self-explanatory:

* meta - `team` (three letter abbreviation), `season`, `division`,
* season outcomes - `points_scored`, `points_allowed`, `score_differential`, `wins`, `losses`, `ties`.

The remaining columns correspond to offensive and defensive summaries of the team's
performance in the season separated by pass and run plays: either `pass_` or `run_`, and
displaying offensive (`_off_`) versus the team's defensive (`_def_`) statistics. The columns that include
`*_n_*` in their name are referring to counts of events such as `off_n_run_touchdowns` 
is referring to the number of offensive running touchdowns scored by the team (`def_n_run_touchdowns` 
refers to running touchdowns allowed on defense by the team). Additionally, there
are columns corresponding to the `*_yards_gained` or `*_yards_allowed` as well as
the completion percentage, `*_completion_perc`, on passing plays.

# NBA team season summary data

Each row in the [nba_team_season_summary.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_projects/nba_team_season_summary.csv) dataset corresponds to a single NBA team in a single regular
season dating back to 2003. The column names self-explanatory, but note that the columns ending with
`*_perc` mean the percentage based statistics.

# NHL team season summary data

Each row in the [nhl_team_season_summary.csv](https://raw.githubusercontent.com/ryurko/CMSACamp/master/data/regression_projects/nhl_team_season_summary.csv) dataset corresponds to a single NHL team in a single regular
season dating back to 2007. The full glossary for the columns in this dataset
can be found here: https://evolving-hockey.com/ (click on the __More__ tab, then select __Glossary__).


