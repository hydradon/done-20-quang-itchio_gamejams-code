# -*- coding: utf-8 -*-
import scrapy
from twisted.python import log as twisted_log
import logging
import sys
import os
import pandas as pd
import numpy as np
import idna
from non_comp_game_details_crawler.items import NonCompGameDetailsCrawlerItem


class NoncompgamedetailsSpider(scrapy.Spider):
    name = 'noncompgamedetails'
    logging.basicConfig(level=logging.INFO, handlers=[logging.FileHandler('all_game_details_crawler.log', 'w', 'utf-8-sig')])
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    # Allow URL with underscore to be crawled. For ex https://dj_pale.itch.io/unknown-grounds
    idna.idnadata.codepoint_classes['PVALID'] = tuple(
        sorted(list(idna.idnadata.codepoint_classes['PVALID']) + [0x5f0000005f])
    )

    allowed_domains = ['itch.io']
    base_url = 'https://www.itch.io'
    start_urls = ['https://itch.io/login']

    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)
    greatGrandParentDir = os.path.dirname(grandParentDir)

    df = pd.read_csv(os.path.join(greatGrandParentDir + "\\dataset", 'jams.csv'))
    # df['jam_criteria'] = df['jam_criteria'].replace(np.nan, '', regex=True)
    # df = df[df['jam_criteria'].map(len) == 0]

    crawl_urls = [x + "/entries" for x in df["jam_url"].tolist()]

    # crawl_urls = ['https://itch.io/jam/game-off-2018/entries']

    def parse(self, response):
        token = response.xpath('//*[@name="csrf_token"]/@value').extract_first()
        return [scrapy.FormRequest.from_response(response,
                                                 formdata={'csrf_token': token,
                                                           'password': '', #TODO use own usename and pass!
                                                           'username': ''},
                                                 formcss='.login_form_widget .form',
                                                 callback=self.check_login_response)]

    def check_login_response(self, response):
        if b"Incorrect username or password" in response.body:
            self.log("Login failed", level=logging.ERROR)
            return
        else:
            self.log("Successfully logged in!!")
            for url in self.crawl_urls:
                yield scrapy.Request(url=url, callback=self.scrape)

    def scrape(self, response):
        for game in response.css('div[data-game_id]'):
            item = NonCompGameDetailsCrawlerItem()

            item['jam_url'] = response.url.replace("/entries", "")
            item['game_submission_page'] = item['jam_url'] + "/rate/" + str(game.css("::attr(data-game_id)").extract_first())
            item['jam_name'] = response.css(".jam_title_header ::text").extract_first()
            item['game_url'] = game.css('.title ::attr(href)').extract_first()
           
            # yield item
            # request = scrapy.Request(item['game_url'], callback=self.get_game_details)
            request = scrapy.Request(item['game_submission_page'], callback=self.get_game_url)
            request.meta['item'] = item

            yield request

    def get_game_url(self, response):
        item = response.meta['item']

        # Get game source code URL if available
        SOURCE_REPO_SELECTOR = ".//*[text()='GitHub repository']/following-sibling::a/@href"
        source_code_link = response.xpath(SOURCE_REPO_SELECTOR).extract_first()
        item['game_source_code'] = source_code_link if source_code_link and "itch.io" not in source_code_link else ""

        # Obtain game rankings/scores/raw scores from table
        game_criteria = []
        game_ranks = []
        game_scores = []
        game_raw_scores = []

        rankings = response.xpath('.//table[@class="nice_table ranking_results_table"]//tr')
        for ranking in rankings[1:]:

            criteria = ranking.xpath('td[1]/descendant-or-self::text()').extract_first()
            rank = ranking.xpath('td[2]/descendant-or-self::text()').extract_first().replace('#', '')
            score = ranking.xpath('td[3]/descendant-or-self::text()').extract_first(default = "")
            raw_score = ranking.xpath('td[4]/descendant-or-self::text()').extract_first(default = "")

            game_criteria.append(criteria)
            game_ranks.append(rank)
            game_scores.append(score)
            game_raw_scores.append(raw_score)

        item['game_criteria'] = "||".join(game_criteria)
        item['game_ranks'] = "||".join(game_ranks)
        item['game_scores'] = "||".join(game_scores)
        item['game_raw_scores'] = "||".join(game_raw_scores)
        
        item['game_no_ratings'] = response.css(".jam_game_results strong ::text")\
                                          .extract_first(default = "")\
                                          .replace(" ratings", "")\
                                          .replace(" rating", "")

        request = scrapy.Request(item['game_url'], callback=self.get_game_details)
        request.meta['item'] = item
        yield request

    def get_game_details(self, response):
        item = response.meta['item']

        # Check if game requires password to view
        passtag = response.css(".game_password_page")
        if passtag:
            item['game_status'] = 'A password is required to view this page'
            yield item
            return

        GAME_NAME_SELECTOR = ".game_title ::text"
        item['game_name'] = response.css(GAME_NAME_SELECTOR).extract_first()

        GAME_DESC_SELECTOR = ".formatted_description *::text"
        description = response.css(GAME_DESC_SELECTOR).extract()
        item['game_desc_len'] = len("".join(description).replace('\n', ''))

        # Extract github location
        # example multiple github links: https://hunterkepley.itch.io/ice
        if not item['game_source_code']:
            self.log("Game source code not found in Submission page", level=logging.INFO)
            all_links = response.css("a ::attr(href)").extract()
            githubs = [s for s in all_links 
                        if "github.com/" in s or 
                        "gitlab.com/" in s or 
                        "bitbucket.org/" in s]
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
                # print(row_key)
                info[row_key] = row.css("abbr ::attr(title)").extract_first()
            elif ("author" in row_key.lower()) or ("authors" in row_key.lower()):
                info[row_key] = "||".join(row.xpath("td[2]/a/text()").extract())
                info["Author's Url"] = "||".join(row.xpath("td[2]/a/@href").extract())
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
        item["game_asset_license"]   = info.get("Asset license", "")
        item["game_developers"]      = info.get("Author", info.get("Authors", ""))
        item["game_developers_url"]  = info.get("Author's Url", "")
        item["game_multiplayer"]     = info.get("Multiplayer", "")

        # Download section
        UPLOAD_SELECTOR = ".upload"
        all_uploads = response.css(UPLOAD_SELECTOR)
        download_infos = []
        for upload in all_uploads:
            upload_date = upload.css(".upload_date *::attr(title)").extract_first(default = "")
            upload_size = upload.css(".file_size ::text").extract_first(default = "")
            upload_name = upload.css(".upload_name .name ::text").extract_first()
            upload_platform = [plf.replace("Download for ", "") for plf in upload.css(".download_platforms *::attr(title)").extract()]
            download_infos.append(upload_name + "||" + upload_size + "||" + upload_date + '||' + "||".join(upload_platform))

        item['game_size'] = "<>".join(download_infos)

        yield item
        