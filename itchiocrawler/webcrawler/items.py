# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class WebcrawlerItem(scrapy.Item):
    # define the fields for your item here like:
    jam_name = scrapy.Field()
    jam_url = scrapy.Field()
    jam_no_joined = scrapy.Field()
    jam_no_submissions = scrapy.Field()
    jam_start_date = scrapy.Field()
    jam_end_date = scrapy.Field()
    jam_no_rating = scrapy.Field()
    # jam_community_activity = scrapy.Field()
    jam_criteria = scrapy.Field()
    jam_host = scrapy.Field()