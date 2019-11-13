# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class GameDetailsCrawlerItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    game_name = scrapy.Field()
    game_url = scrapy.Field()
    game_price = scrapy.Field()
    game_last_update = scrapy.Field()
    game_developers = scrapy.Field()
    game_developers_url = scrapy.Field()
    game_publish_date = scrapy.Field()
    game_desc_len = scrapy.Field()
    game_no_screenshots = scrapy.Field()
    game_status = scrapy.Field()
    game_platforms = scrapy.Field()
    game_genres = scrapy.Field()
    game_tags = scrapy.Field()
    game_size = scrapy.Field()
    game_made_with = scrapy.Field()
    game_ave_session = scrapy.Field()
    game_language = scrapy.Field()
    game_inputs = scrapy.Field()
    game_accessibility = scrapy.Field()
    game_source_code = scrapy.Field()
    game_license = scrapy.Field()
    game_asset_license = scrapy.Field()
    game_release_date = scrapy.Field()

