# -*- coding: utf-8 -*-
require 'rubygems'
require 'amazon/aws'
require 'amazon/aws/search'

ENV['AMAZONRCDIR']  = '' # PATH
ENV['AMAZONRCFILE'] = 'amazonrc'

#
# It is necessary to create a amazonrc
#
#[global]
#  key_id        = {AWS Access Key ID}
#  secret_key_id = {AWS Secret Access Key}
#  associate     = {Amazon Associate ID}
#  locale        = jp
#  cache         = true
#  cache_dir     = {Cache Directory}
#

class AmazonSearch < SkypeBot::Plugin
  def initialize(*args)
    super
    @prefix = @config['prefix'] || 'が欲しい'
    @limit  = @config['limit'] || 3
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+)#{@prefix}$/
      search($1).each do |item|
        sendMessage(channel, item)
      end
    end
  end

  private

  def search(keyword)
    begin
      request  = Amazon::AWS::Search::Request.new
      query    = Amazon::AWS::ItemSearch.new(:All, { :Keywords => keyword })
      response = Amazon::AWS::ResponseGroup.new(:Small, :OfferSummary)

      datas   = []
      results = request.search(query, response).item_search_response.items.item

      results[0...@limit].each do |item|
        title  = item.item_attributes.title.to_s
        uri    = item.detail_page_url.to_s
        prices = item.offer_summary
        price  = case
                 when prices.lowest_new_price : prices.lowest_new_price.formatted_price
                 when prices.lowest_used_price : "[中古] #{prices.lowest_used_price.formatted_price}"
                 when prices.lowest_collectible_price : "[コレクター] #{prices.lowest_collectible_price.formatted_price}"
                 end

        datas << "これかな？ [Amazon.co.jp] #{title} #{price} (#{URI.short_uri(uri)})"
      end
      return datas
    rescue Exception => e
      p e.inspect
      return 'うーん、なにそれ？みつからないよー。'
    end
  end
end
