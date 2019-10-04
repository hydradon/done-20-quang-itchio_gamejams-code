# -*- coding: utf-8 -*-
import scrapy
from webcrawler.items import WebcrawlerItem
from twisted.python import log as twisted_log
import logging

class ItchioSpider(scrapy.Spider):

    logging.basicConfig(level=logging.INFO, filemode='w', filename='jam_crawler.log')
    observer = twisted_log.PythonLoggingObserver()
    observer.start()

    name = 'itchio'
    base_url = 'https://www.itch.io'
    allowed_domains = ['itch.io']
    start_urls = [base_url + '/jams/past/']
    # start_urls = ['https://itch.io/jams/past?page=1']

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
       
        for jam in response.css('.jam'):
            
            item = WebcrawlerItem()  # Creating a new Item object

            JAM_NAME_SELECTOR = '.primary_info ::text'
            JAM_URL_SELECTOR = '.primary_info a ::attr(href)'
            JAM_NO_JOINED_SELECTOR = './/div[@class = "jam_stats"]/div/span/text()'
            JAM_NO_SUBMISSION_SELECTOR = './/div[@class = "jam_stats"]/a/span/text()'

            item['jam_name'] = jam.css(JAM_NAME_SELECTOR).extract_first(),
            item['jam_url'] = self.base_url + jam.css(JAM_URL_SELECTOR).extract_first()
            item['jam_no_joined'] = int(jam.xpath(JAM_NO_JOINED_SELECTOR).extract_first(default='0').replace(',', ''))
            item['jam_no_submissions'] = int(jam.xpath(JAM_NO_SUBMISSION_SELECTOR).extract_first(default='0').replace(',', ''))

            request = scrapy.Request(item['jam_url'], callback=self.get_more_jam_details)
            request.meta['item'] = item #By calling .meta, we can pass our item object into the callback.
            yield request #Return the item + details back to the parser.

    def get_more_jam_details(self, response):
        
        # get more details in each jam's page
        item = response.meta['item'] #Get the item we passed from scrape()   

        JAM_NO_RATING_SELECTOR = ".//div[text()='Ratings']/preceding-sibling::div/text()"
        item['jam_no_rating'] = response.xpath(JAM_NO_RATING_SELECTOR).extract_first(default='0').replace(',', '')

        # JAM_NO_ENTRIES_SELECTOR = ".//div[text()='Entries']/preceding-sibling::div/text()"
        # item['jam_no_rating'] = response.xpath(JAM_NO_RATING_SELECTOR).extract_first()

        JAM_DATE_SELECTOR = '.date_format ::text'
        item['jam_start_date'] = response.css(JAM_DATE_SELECTOR).extract()[0]
        item['jam_end_date'] = response.css(JAM_DATE_SELECTOR).extract()[1]


        result_page = response.xpath(".//a[text()='Results']/@href").extract_first()
        if result_page:
            request = scrapy.Request(self.base_url+result_page, callback=self.get_jam_criteria)
            request.meta['item'] = item
            yield request
        else: 
            yield item

    def get_jam_criteria(self, response):
        item = response.meta['item']

        JAM_CRITERIA_SELECTOR = '.criteria_sort_inner a ::text'
        item['jam_criteria'] = "||".join(response.css(JAM_CRITERIA_SELECTOR).extract())
        # print("Jam name {}".format(item['jam_name']))
        # print("Jam jam_criteria {}".format(item['jam_criteria']))
        # input("waiting for input...")

        yield item