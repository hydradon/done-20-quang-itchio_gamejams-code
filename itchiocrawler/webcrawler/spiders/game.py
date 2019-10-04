# -*- coding: utf-8 -*-
import scrapy
from webcrawler.items import WebcrawlerItem
from twisted.python import log as twisted_log
import logging
import pandas as pd
import sys
import os

class GameSpider(scrapy.Spider):
    logging.basicConfig(level=logging.INFO, filemode='w', filename='game_crawler_log.txt')
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    name = 'game'
    allowed_domains = ['https://itch.io/jams/past/']

    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)


    df = pd.read_csv(os.path.join(grandParentDir, 'jams1-filter.csv'))
    start_urls = df["jam_url"].tolist()[0]
    print(start_urls)

    def parse(self, response):
        pass
