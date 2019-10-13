# -*- coding: utf-8 -*-
import scrapy
from twisted.python import log as twisted_log
from game_details_crawler.items import GameDetailsCrawlerItem
import logging
import pandas as pd
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

    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)
    greatGrandParentDir = os.path.dirname(grandParentDir)

    df = pd.read_csv(os.path.join(greatGrandParentDir, 'dataset/game_rankings.csv'))
    no_of_games = len(df["game_url"].tolist())

    # start_urls = [game_url for game_url in df["game_url"].tolist()]
    start_urls = ['https://itch.io/login']
    crawl_urls = ['https://dmullinsgames.itch.io/paper-jekyll', 
                  'https://hunterkepley.itch.io/ice',
                  'https://dj_pale.itch.io/unknown-grounds']
    crawl_urls = [game_url for game_url in df["game_url"].tolist()]

    def parse(self, response):
        token = response.xpath('//*[@name="csrf_token"]/@value').extract_first()
        return [scrapy.FormRequest.from_response(response,
                                                 formdata={'csrf_token': token,
                                                           'password': 'nosalis9)',
                                                           'username': 'hydradon'},
                                                 formcss='.login_form_widget .form',
                                                 callback=self.check_login_response)]

    def check_login_response(self, response):
        if b"Incorrect username or password" in response.body:
            self.log("Login failed", level=logging.ERROR)
            return
        else:
            self.log("Successfully logged in!!")
            for url in self.crawl_urls:
                self.log("Number of games left: " + str(self.no_of_games))
                self.no_of_games -= 1
                yield scrapy.Request(url=url, callback=self.scrape)

    def scrape(self, response):
        item = GameDetailsCrawlerItem()
        item['game_url'] = response.url

        GAME_NAME_SELECTOR = ".game_title ::text"
        item['game_name'] = response.css(GAME_NAME_SELECTOR).extract_first()

        GAME_DESC_SELECTOR = ".formatted_description *::text"
        description = response.css(GAME_DESC_SELECTOR).extract()
        item['game_desc_len'] = len("".join(description).replace('\n', ''))

        # Extract github location
        # example multiple github links: https://hunterkepley.itch.io/ice
        all_links = response.css("a ::attr(href)").extract()
        githubs = [s for s in all_links if "github.com/" in s or "gitlab.com/" in s]
        item['game_source_code'] = "||".join(githubs) if len(githubs) > 0 else ""

        # Couting number of screenshots
        item['game_no_screenshots'] = len(response.css(".screenshot") + response.css(".formatted_description img"))

        # Extract game price
        GAME_PRICE_SELECTOR = ".buy_message ::text"
        item["game_price"] = response.css(GAME_PRICE_SELECTOR).extract_first()

        # Extract "More information" section
        GAME_INFO_TABLE_ROW_SELECTOR = ".game_info_panel_widget table tr"
        info_rows = response.css(GAME_INFO_TABLE_ROW_SELECTOR)
        info = {}
        for row in info_rows:
            row_key = row.xpath("td[1]/text()").extract_first()
            if ("update" in row_key.lower()) or ("publish" in row_key.lower()) or ("release" in row_key.lower()):
                print(row_key)
                info[row_key] = row.css("abbr ::attr(title)").extract_first()
            else:
                info[row_key] = "||".join(row.xpath("td[2]/a/text()").extract())

        item["game_last_update"]     = info.get("Updated", "")
        item["game_publish_date"]    = info.get("Published", "")
        item["game_release_date"]    = info.get("Release date", "")
        item["game_status"]          = info.get("Status", "")
        item["game_platforms"]       = info.get("Platforms", "")
        item["game_genres"]          = info.get("Genre", "")
        item["game_tags"]            = info.get("Tags", "")
        item["game_made_with"]       = info.get("Made with", "")
        item["game_ave_session"]     = info.get("Average session", "")
        item["game_language"]        = info.get("Languages", "")
        item["game_inputs"]          = info.get("Inputs", "")
        item["game_accessibility"]   = info.get("Accessibility", "")
        item["game_license"]         = info.get("License", "")
        item["game_asset_license"]  = info.get("Asset license", "")

        # Download section
        UPLOAD_SELECTOR = ".upload"
        all_uploads = response.css(UPLOAD_SELECTOR)
        download_infos = []
        for upload in all_uploads:
            upload_date = upload.css(".upload_date *::attr(title)").extract_first(default = "")
            upload_size = upload.css(".file_size ::text").extract_first(default = "")
            upload_name = upload.css(".upload_name .name ::text").extract_first()
            upload_platform = [plf.replace("Download for ", "") for plf in upload.css(".download_platforms *::attr(title)").extract()]
            download_infos.append(upload_name + "|" + upload_size + "|" + upload_date + '|' + "|".join(upload_platform))

        item['game_size'] = "<>".join(download_infos)

        yield item