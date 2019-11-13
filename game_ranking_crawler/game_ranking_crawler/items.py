# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class GameRankingCrawlerItem(scrapy.Item):
    # define the fields for your item here like:
    game_name = scrapy.Field()
    game_url = scrapy.Field()
    game_submission_page_url = scrapy.Field()
    game_developers = scrapy.Field()
    game_developers_url = scrapy.Field()
    jam_url = scrapy.Field()
    jam_result_page = scrapy.Field()
    jam_name = scrapy.Field()
    game_criteria = scrapy.Field()
    game_ranks = scrapy.Field()
    game_scores = scrapy.Field()
    game_raw_scores = scrapy.Field()
