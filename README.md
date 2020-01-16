# Spiders

## itchio

This spider crawls the main page [https://itch.io/jams/past](https://itch.io/jams/past) for jams and their information: ranking details, duration, number of submissions.

### Run

```
cd itchiocrawler
scrapy crawl itchio
```


## gameranking
This spider crawls each jam's submission page for a list of its game entries and retrieves the ranking details of its games. Data is saved in `../dataset/game_rankings.csv`

[game_rankings.csv](./dataset/game_rankings.csv)

### Run

```
cd game_ranking_crawler
scrapy crawl gameranking
```

## H2

## H2

## H2