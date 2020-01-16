# I. Spiders

## itchio

This spider crawls the main page [https://itch.io/jams/past](https://itch.io/jams/past) for jams and their information: ranking details, duration, number of submissions. The data is stored under [jams-raw.csv](./dataset/jams-raw.csv).

### Run

```
cd itchiocrawler
scrapy crawl itchio
```

## jamdesc

This spider crawls 

### Run

```
cd jam_desc_crawler
scrapy crawl jamdesc
```



## gameranking
This spider crawls each jam's submission page for a list of its game entries and retrieves the ranking details of its games. Data is saved in [game_rankings.csv](./dataset/game_rankings.csv).

### Run

```
cd game_ranking_crawler
scrapy crawl gameranking
```

## H2

## H2

## H2