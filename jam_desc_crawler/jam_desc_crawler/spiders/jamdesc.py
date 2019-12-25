# -*- coding: utf-8 -*-
import scrapy
from twisted.python import log as twisted_log
from jam_desc_crawler.items import JamDescCrawlerItem
import logging
import pandas as pd
import os

class JamdescSpider(scrapy.Spider):

    logging.basicConfig(level=logging.INFO, handlers=[logging.FileHandler('jam_desc_crawler.log', 'w', 'utf-8-sig')])
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    name = 'jamdesc'
    allowed_domains = ['itch.io']
    base_url = 'https://www.itch.io'

    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)
    greatGrandParentDir = os.path.dirname(grandParentDir)

    df = pd.read_csv(os.path.join(greatGrandParentDir + "\\dataset", 'jams1.csv'))

    start_urls = df["jam_url"].tolist()

    start_urls = df["jam_url"].tolist()[:10]
    start_urls = ["https://itch.io/jam/cyberpunk-jam"]

    def parse(self, response):

        item = JamDescCrawlerItem()
        item['jam_url'] = response.url.replace("itch.io:443", "www.itch.io")
    
        # JAM_DESC_SELECTOR = ".jam_content *::text"
        description = response.css(".jam_content *:not(style)::text").extract()
        item['jam_desc_len'] = len("".join(description).replace('\t', '').replace('\r', '').replace('\n', ''))

        # Counting number of illustrations
        item['jam_no_illustrations'] = len(response.css(".jam_content img"))

        # Counting number of video
        item['jam_no_videos'] = len(response.css("iframe"))

        yield item