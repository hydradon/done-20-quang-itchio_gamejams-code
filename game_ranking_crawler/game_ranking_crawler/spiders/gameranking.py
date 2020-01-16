# -*- coding: utf-8 -*-
import scrapy
import pandas as pd
from game_ranking_crawler.items import GameRankingCrawlerItem
from twisted.python import log as twisted_log
import logging
import sys
import os


class GamerankingSpider(scrapy.Spider):
    logging.basicConfig(level=logging.INFO, handlers=[logging.FileHandler('game_ranking_crawler.log', 'w', 'utf-8-sig')])
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    name = 'gameranking'
    allowed_domains = ['itch.io']
    base_url = 'https://www.itch.io'

    fileDir = os.path.dirname(os.path.abspath(__file__))
    parentDir = os.path.dirname(fileDir)
    grandParentDir = os.path.dirname(parentDir)
    greatGrandParentDir = os.path.dirname(grandParentDir)

    df = pd.read_csv(os.path.join(greatGrandParentDir + "\\dataset", 'jams.csv'))

    
    start_urls = [x + "/results" for x in df["jam_url"].tolist()]

    start_urls = [x + "/results" for x in df["jam_url"].tolist() 
                    if "awful-summer-jam-2018" not in x
                    and "hanks-jam" not in x
                    and "awful-holiday-2018" not in x
                    and "hardcore-punk-jam" not in x
                    and "awful-summer-2019" not in x]


    ## NOTE - retrieved by criteria other than Overall
    start_urls = start_urls + ["https://itch.io/jam/awful-summer-jam-2018/results/community-choice",
                                "https://itch.io/jam/hanks-jam/results/youve-got-hanks-for-most-tom-hanks",
                                "https://itch.io/jam/awful-holiday-2018/results/most-festive",
                                "https://itch.io/jam/hardcore-punk-jam/results/fan-favourite",
                                "https://itch.io/jam/awful-summer-2019/results/best-solo-entry"]

    print(start_urls)

    def parse(self, response):
        for item in self.scrape(response):
            yield item

        #crawl next page
        next_page = response.css('.next_page ::attr(href)').extract_first()
        if next_page:
            next_page_url = response.urljoin(next_page)
            print("Found url: {}".format(next_page_url))
            # input("Press to continue...")
            yield scrapy.Request(
                next_page_url,
                callback=self.parse
            )

    def scrape(self, response):
        
        for game in response.css(".game_rank"):

            item = GameRankingCrawlerItem()
            item['jam_result_page'] = response.url
            item['jam_url'] = response.url[:response.url.find("/results")]
        
            JAM_NAME_SELECTOR = ".jam_title_header ::text"
            item['jam_name'] = response.css(JAM_NAME_SELECTOR).extract_first()

            GAME_NAME_SELECTOR = ".game_summary ::text"
            GAME_URL_SELECTOR = ".game_summary a ::attr(href)"
            GAME_MADE_BY_SELECTOR = ".game_summary h3 a ::text"
            GAME_DEVELOPERS_URL_SELECTOR = ".game_summary h3 a ::attr(href)"
            GAME_SUBMISSION_PAGE_SELECTOR = ".game_summary p a ::attr(href)"

            item['game_name'] = game.css(GAME_NAME_SELECTOR).extract_first()
            item['game_url'] = game.css(GAME_URL_SELECTOR).extract_first()
            item['game_submission_page_url'] = self.base_url + game.css(GAME_SUBMISSION_PAGE_SELECTOR).extract_first()
            item['game_developers'] = "||".join(game.css(GAME_MADE_BY_SELECTOR).extract())
            item['game_developers_url'] = "||".join(game.css(GAME_DEVELOPERS_URL_SELECTOR).extract())

            # Obtain game rankings/scores/raw scores from table
            game_criteria = []
            game_ranks = []
            game_scores = []
            game_raw_scores = []

            rankings = game.xpath('.//table[@class="nice_table ranking_results_table"]//tr')
            for ranking in rankings[1:]:

                criteria = ranking.xpath('td[1]/descendant-or-self::text()').extract_first()
                rank = ranking.xpath('td[2]/descendant-or-self::text()').extract_first().replace('#', '')
                score = ranking.xpath('td[3]/descendant-or-self::text()').extract_first()
                raw_score = ranking.xpath('td[4]/descendant-or-self::text()').extract_first()

                game_criteria.append(criteria)
                game_ranks.append(rank)
                game_scores.append(score)
                game_raw_scores.append(raw_score)

            item['game_criteria'] = "||".join(game_criteria)
            item['game_ranks'] = "||".join(game_ranks)
            item['game_scores'] = "||".join(game_scores)
            item['game_raw_scores'] = "||".join(game_raw_scores)

            # input("Press to continue...")

            yield item