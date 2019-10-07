# -*- coding: utf-8 -*-
import scrapy
from twisted.python import log as twisted_log
from game_details_crawler.items import GameDetailsCrawlerItem
import logging
import pandas as pd
import sys
import os
import idna

class GamedetailsSpider(scrapy.Spider):

    logging.basicConfig(level=logging.INFO, filemode='w', filename='game_details_crawler.log')
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    # Allow URL with underscore to be crawled. For ex https://dj_pale.itch.io/unknown-grounds
    idna.idnadata.codepoint_classes['PVALID'] = tuple(
        sorted(list(idna.idnadata.codepoint_classes['PVALID']) + [0x5f0000005f])
    )

    name = 'gamedetails'
    allowed_domains = ['itch.io']
    base_url = 'https://www.itch.io'

    
    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)
    greatGrandParentDir = os.path.dirname(grandParentDir)

    df = pd.read_csv(os.path.join(greatGrandParentDir, 'dataset/game_rankings.csv'))
    no_of_games = len(df["game_url"].tolist())

    # start_urls = [game_url for game_url in df["game_url"].tolist()]
    # start_urls = [df["game_url"].tolist()[-no_of_games/100:]]   # crawl 1/100 of the dataset

    start_urls = ['https://dj_pale.itch.io/unknown-grounds']

    def parse(self, response):
        for item in self.scrape(response):
            yield item

    def scrape(self, response):
        item = GameDetailsCrawlerItem()
        item['game_url'] = response.url

        GAME_NAME_SELECTOR = ".game_title ::text"
        item['game_name'] = response.css(GAME_NAME_SELECTOR).extract_first()

        GAME_DESC_SELECTOR = ".formatted_description *::text"
        description = response.css(GAME_DESC_SELECTOR).extract()
        item['game_desc_len'] = len("".join(description).replace('\n', ''))
        # print(item['game_desc_len'])

        # Couting number of screenshots
        item['game_no_screenshots'] = len(response.css(".screenshot") + response.css(".formatted_description img"))
        # print(item['game_no_screenshots'])

        # Extract game download size
        GAME_SIZE_SELECTOR = ".file_size ::text"
        item["game_size"] = "||".join(response.css(GAME_SIZE_SELECTOR).extract())

        # Extract game price
        GAME_PRICE_SELECTOR = ".buy_message ::text"
        item["game_price"] = response.css(GAME_PRICE_SELECTOR).extract_first()

        # Extract "More information" section
        GAME_INFO_TABLE_ROW_SELECTOR = ".game_info_panel_widget table tr"
        info_rows = response.css(GAME_INFO_TABLE_ROW_SELECTOR)
        info = {}
        for row in info_rows:
            row_key = row.xpath("td[1]/descendant-or-self::text()").extract_first()

            if ("update" in row_key.lower()) or ("publish" in row_key.lower()):
                print(row_key)
                info[row_key] = row.css("abbr ::attr(title)").extract_first()
            else:
                info[row_key] = "||".join(row.xpath("td[2]/abbr/text()").extract())

        # input("test")
        # print(info)

        item["game_last_update"]    = info.get("Updated", "")   # TODO
        item["game_publish_date"]   = info.get("Published", "") # TODO
        item["game_status"]         = info.get("Status", "")
        item["game_platforms"]      = info.get("Platforms", "")
        item["game_genres"]         = info.get("Genre", "")
        item["game_tags"]           = info.get("Tags", "")
        item["game_made_with"]      = info.get("Made with", "")
        item["game_ave_session"]    = info.get("Average session", "")
        item["game_language"]       = info.get("Languages", "")
        item["game_inputs"]         = info.get("Inputs", "")
        item["game_accessibility"]  = info.get("Accessibility", "")
    

        yield item