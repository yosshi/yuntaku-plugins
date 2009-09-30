# -*- coding: utf-8 -*-
require 'rubygems'
require 'open-uri'
require 'time'
require 'rss'

class GoogleNews < SkypeBot::Plugin
  def initialize(*args)
    super
    @prefix = @config['prefix'] || '(の)?ニュース教えて'
    @keyword
    @limit = @config['limit'] || 3
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(ヘッドライン|最新|)#{@prefix}/
      getHeadline().each do |m|
        sendMessage(channel, m)
      end
    when /^[\s]{0,}(.+)#{@prefix}/i
      searchNews(Regexp.last_match[1]).each do |m|
        sendMessage(channel, m)
      end
    end
  end

  private
  def searchNews(query)
    # 検索
    query  = URI.encode(query)
    search = "http://news.google.com/news?hl=ja&ned=us&ie=UTF-8&oe=UTF-8&output=rss&q=#{query}"
    messages = getNews(search)
    return messages
  end

  def getHeadline()
    # 最新ニュース
    headline = "http://news.google.com/news?hl=ja&ned=us&ie=UTF-8&oe=UTF-8&output=rss&topic=h"
    messages = getNews(headline)
    return messages
  end

  def getNews(target)
    messages = Array.new()
    rss = open(target){ |file| RSS::Parser.parse(file.read) }
    rss.items[0...@limit].each do |item|
      title = item.title
      url   = URI.short_uri(item.link.scan(/url=(.+)&/).first.to_s)
      date  = item.date.strftime("%Y/%m/%d")
      message = "[#{date}] #{title} (#{url})"
      messages << message
    end
    return messages
  end

end
