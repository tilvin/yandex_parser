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

      link = link_element['href'].gsub(/(http|https):\/\//, '')

      uri_alexa = URI.parse("https://www.alexa.com/siteinfo/#{ link }")
      page_alexa = Nokogiri::HTML(open(uri_alexa.to_s))
      alexa_rank = page_alexa.css(".globleRank .col-pad .metrics-data").text.gsub(/\n\n/,'')


      uri_tiz = URI.parse("https://yandex.ru/yaca/cy/ch/#{ link }")
      page_tiz = Nokogiri::HTML(open(uri_tiz.to_s))
      tiz = page_tiz.css('.cy__not-described-cy').text.match(/\d+/).to_s

      @data << [link_element['href'], alexa_rank.to_i, tiz]
    end
  end

  def create_csv
    CSV.open("rails_file.csv", "wb") do |csv|
      csv << ["ADDRESS", "ALEXA GLOBAL RATE", "YANDEX RATE"]
      @data.sort_by{ |x,y,z| - y }.each do |address, alexa_rate, yandex_rate|
        csv << [address, alexa_rate, yandex_rate]
      end
    end
  end
end
