# I. Spiders

## 1. itchio

This spider crawls the main page [https://itch.io/jams/past](https://itch.io/jams/past) for jams and their information: ranking details, duration, number of submissions. The data is stored under [jams-raw.csv](./dataset/jams-raw.csv).

### Run

```
cd itchiocrawler
scrapy crawl itchio
```

## 2. jamdesc

This spider reads the jam links from [jams-raw.csv](./dataset/jams-raw.csv) and crawls each jam page for its description, screenshots, videos.

### Run

```
cd jam_desc_crawler
scrapy crawl jamdesc
```

## 3. noncompgamedetails
This spider reads [jams-raw.csv](./dataset/jams.csv) and goes to each jam's list of submissions and crawl all game details. This produces [all_game_details.csv](./dataset/all_game_details.csv).

### Run
```
cd non_comp_game_details_crawler
scrapy crawl noncompgamedetails
```

# II. Data cleaning, preprocessing

## 1. Cleaning jams

Notebook: [select_jams.ipynb](./analysis_notebooks/select_jams.ipynb).

=> Final jam dataset: 
- [competitive_jams_cleaned.csv](./dataset/competitive_jams_cleaned.csv).
- [non_competitive_jams_cleaned.csv](./dataset/non_competitive_jams_cleaned.csv).

## 2. Cleaning games

Notebook: [select_games.ipynb](./analysis_notebooks/select_games.ipynb).

=> Final game dataset: 
- [games_cleaned.csv](./dataset/games_cleaned.csv) => for model building.

# III. Analysis

## 1. Jams analysis
Dataset used: [competitive_jams_cleaned.csv](./dataset/competitive_jams_cleaned.csv) and [non_competitive_jams_cleaned.csv](./dataset/non_competitive_jams_cleaned.csv).

R scripts:
- Load and prepare data: [rq1-load-data.r](./R_game_analysis/rq1-load-data.r).
- Model building, analysis: [rq1-competitive-jams.r](./R_game_analysis/rq1-competitive-jams.r) and [rq1-non-competitive-jams.r](./R_game_analysis/rq1-non-competitive-jams.r).


## 2. Games analysis

Dataset used: [games_cleaned.csv](./dataset/games_cleaned.csv)

R scripts:
- Load and prepare data: [rq2-load-data.r](./R_game_analysis/rq2-load-data.r).
- Model building, analysis: [rq2.r](./R_game_analysis/rq2.r).
