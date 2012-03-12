require 'JSON'
require 'net/http'
require 'uri'
require 'time'

class NewsFetcher < TeBot::Plugin
  def initialize(bot_instance)
    @bot_instance = bot_instance
    @articles = []
    fetch_articles(true) # Fetch them silently first so we have a "base"
    puts @bot_instance.channels
    fetcher = Thread.new do
      while true
        fetch_articles
        sleep(10)
      end
    end
  end
  
  def fetch_articles(silent = false)
    base_url = "http://te-beta.herokuapp.com"
    url = "#{base_url}/articles.json"
    content = JSON.parse Net::HTTP.get(URI.parse(url))
    
    
    if !silent && content != @articles
      # We have new articles
      new_content = (content - @articles)
      new_content.each do |article|
        title = article["title"]
        date = Time.parse(article["updated_at"]).strftime("%e/%-m/%Y %H:%M")
        link = "#{base_url}/#{article["slug"]}"
        @bot_instance.channels.each do |channel, nicks|
          @bot_instance.send_to(channel, "NEWS: (#{date}) #{title} - #{link}")
        end
      end
    end
    
    @articles = content
  end
end