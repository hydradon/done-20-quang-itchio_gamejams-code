# -*- coding: utf-8 -*-
import scrapy
import pandas as pd
from game_ranking_crawler.items import GameRankingCrawlerItem
from twisted.python import log as twisted_log
import logging
import pandas as pd
import sys
import os


class GamerankingSpider(scrapy.Spider):

    logging.basicConfig(level=logging.INFO, filemode='w', filename='game_crawler_log.txt')
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    name = 'gameranking'
    allowed_domains = ['https://itch.io/jam']

    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)
    greatGrandParentDir = os.path.dirname(grandParentDir)

    df = pd.read_csv(os.path.join(greatGrandParentDir, 'jams.csv'))

    print(df["jam_url"].tolist()[0])

    start_urls = [x + "/results" for x in df["jam_url"].tolist()]
    # print(start_urls)
    # input("testestsetsetes")
    # start_urls = ['http://https://itch.io/jam/']

    def parse(self, response):
        for item in self.scrape(response):
            yield item
 

    def scrape(self, response):
        
        for game in response.css(".game_rank"):

            item = GameRankingCrawlerItem()

            GAME_NAME_SELECTOR = ".game_summary ::text"
            GAME_URL_SELECTOR = ".game_summary a ::attr(href)"
            GAME_MADE_BY_SELECTOR = ".game_summary h3 a ::text"
            GAME_SUBMISSION_PAGE_SELECTOR = ".game_summary p a ::attr(href)"
    