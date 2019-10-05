# -*- coding: utf-8 -*-
import scrapy
from twisted.python import log as twisted_log
from game_details_crawler.items import GameDetailsCrawlerItem
import logging
import pandas as pd
import sys
import os

class GamedetailsSpider(scrapy.Spider):

    logging.basicConfig(level=logging.INFO, filemode='w', filename='game_details_crawler.log')
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    name = 'gamedetails'
    allowed_domains = ['itch.io']
    base_url = 'https://www.itch.io'

    
    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)
    greatGrandParentDir = os.path.dirname(grandParentDir)

    df = pd.read_csv(os.path.join(greatGrandParentDir, 'game_rankings.csv'))

    start_urls = [df["game_url"].tolist()[0]]

    def parse(self, response):
        for item in self.scrape(response):
            yield item

    def scrape(self, response):
        item = GameDetailsCrawlerItem()
        item['game_url'] = response.url

        GAME_NAME_SELECTOR = ".game_title ::text"
        item['game_name'] = response.css(GAME_NAME_SELECTOR).extract_first()

        GAME_DESC_SELECTOR = ".formatted_description"
        item['game_desc_len'] = len(response.css(GAME_DESC_SELECTOR).extract_first(default=''))
        print(item['game_desc_len'])
        input("test...")

        yield item