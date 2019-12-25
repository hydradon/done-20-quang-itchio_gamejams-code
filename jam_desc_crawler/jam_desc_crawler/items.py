# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class JamDescCrawlerItem(scrapy.Item):
    # define the fields for your item here like:
    jam_url = scrapy.Field()
    jam_no_illustrations = scrapy.Field()
    jam_desc_len = scrapy.Field()
    jam_no_videos = scrapy.Field()
