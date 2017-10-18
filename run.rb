require_relative 'yandex_parser'
if YandexParser.new('rails').processing
  puts 'parsing complete'
end