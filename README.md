# I. Spiders

## 1. itchio

This spider crawls the main page [https://itch.io/jams/past](https://itch.io/jams/past) for jams and their information: ranking details, duration, number of submissions. The data is stored under [jams-raw.csv](./dataset/jams-raw.csv). The data needs to be cleaned first by running this script [cleaning_jams_raw_data.py](./Python_scripts/cleaning_jams_raw_data.py), which produces [jams.csv](./dataset/jams.csv).

### Run

```
cd itchiocrawler
scrapy crawl itchio
```

## 2. jamdesc

This spider reads the jam links from [jams.csv](./dataset/jams.csv) and crawls each jam page for its description, screenshots, videos.

### Run

```
cd jam_desc_crawler
scrapy crawl jamdesc
```

## 3. noncompgamedetails
This spider reads [jams.csv](./dataset/jams.csv) and goes to each jam's list of submissions and crawl all game details. This produces [all_game_details.csv](./dataset/all_game_details.csv), which needs to be cleaned by [cleaning_game_data.py](./Python_scripts/cleaning_game_data.py), which produces [all_games_details_cleaned.csv](./dataset/all_games_details_cleaned.csv).

### Run
```
cd non_comp_game_details_crawler
scrapy crawl noncompgamedetails
```

## 4. gameranking (**OUTDATED**)
This spider crawls each jam's submission page for a list of its game entries and retrieves the ranking details of its games. Data is saved in [game_rankings.csv](./dataset/game_rankings.csv). Therefore, this crawler only produces data of games that have been submitted to competitive jams.

### Run

```
cd game_ranking_crawler
scrapy crawl gameranking
```

## 5. gamedetails (**OUTDATED**)
This spider reads [game_rankings.csv](./dataset/game_rankings.csv) to get a list of all games that have been submitted and **RANKED** in competitive jams and produces [game_details.csv](./dataset/game_details.csv).

### Run
```
cd game_details_crawler
scrapy crawl gamedetails
```

# II. Data cleaning, preprocessing

## 1. Cleaning jams

a. Initial cleaning:

Script: [cleaning_jams_raw_data.py](./Python_scripts/cleaning_jams_raw_data.py)
```
python ./Python_scripts/cleaning_jams_raw_data.py
```

b. Seleting top and bottom 20% jams in terms of number of submissions:

Script: [selecting_jams_for_models.py](./Python_scripts/selecting_jams_for_models.py)
```
python ./Python_scripts/selecting_jams_for_models.py
```

=> Final produced dataset: 
- [competitive_jams_cleaned.csv](./dataset/competitive_jams_cleaned.csv)
-  [non_competitive_jams_cleaned.csv](./dataset/non_competitive_jams_cleaned.csv)

## 2. Cleaning game details

a. Initial cleaning:
Script: [cleaning_game_data.py](./Python_scripts/cleaning_game_data.py)
```
python ./Python_scripts/cleaning_game_data.py
```

b. Seleting top and bottom 20% games in terms of ranking:

Script: [selecting_games_for_models.py](./Python_scripts/selecting_games_for_models.py)
```
python ./Python_scripts/selecting_games_for_models.py
```

=> Final dataset: 
- [games_cleaned_before_encoding.csv](./dataset/games_cleaned_before_encoding.csv)
- [games_cleaned.csv](./dataset/games_cleaned.csv) => This dataset is an encoded version of the above, for model building.

# III. Analysis

## 1. Jams analysis
Dataset used: [competitive_jams_cleaned.csv](./dataset/competitive_jams_cleaned.csv) and [non_competitive_jams_cleaned.csv](./dataset/non_competitive_jams_cleaned.csv)

R scripts:
- 


## 2. Games analysis

Dataset used: [games_cleaned.csv](./dataset/games_cleaned.csv)