require 'open-uri'
require 'nokogiri'
require 'csv'

class YandexParser

  def initialize(keyword)
    @keyword = keyword
  end

  def processing
    parsing
    create_csv
  end

  private

  def parsing
    uri = URI.parse("https://yandex.ru/search/?text=#{@keyword}")
    @page = Nokogiri::HTML(open(uri.to_s))

    @data = []
    @page.css(".serp-item.t-construct-adapter__legacy .link.link_theme_normal.organic__url").each do |link_element|
      uri_alexa = URI.parse("https://www.alexa.com/siteinfo/#{link_element['href']}")
      @page_alexa = Nokogiri::HTML(open(uri_alexa.to_s))
      rank = @page_alexa.css(".globleRank .col-pad .metrics-data").text.gsub(/\n\n/,'')
      @data << [link_element['href'], rank.to_i]
    end
  end

  def create_csv
    CSV.open("rails_file.csv", "wb") do |csv|
      csv << ["ADDRESS", "ALEXA GLOBAL RATE"]
      @data.sort_by(&:last).reverse.each do |address, rate|
        csv << [address, rate]
      end
    end
  end
end
