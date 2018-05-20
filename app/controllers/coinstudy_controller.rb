
require 'net/http'
require 'uri'
require 'json'
require 'date'

class CoinstudyController < ApplicationController

  def index

    keyword = params[:keyword]
    date = params[:date]

    def get_json(url)
      uri = URI.parse(URI.escape(url))
      json = Net::HTTP.get(uri)
      result = JSON.parse(json)
    end

  #connpassからの取得
    def connpass(word,ym)
      result = get_json("https://connpass.com/api/v1/event/?keyword=#{word}&ym=#{ym}&count=100")

      puts "connpass #{result["results_available"]}, #{result["results_returned"]}"

      infos = []

      result["events"].each do |val|
        infos << {
          "title" => val["title"],
          "started_at" => val["started_at"],
          "event_url" => val["event_url"],
          "address" => val["address"]
        }
      end
      return infos
    end

  #doorkeeperからの取得
    def doorkeeper(y,m,word)
      year = (m == 12) ? y+1 : y
      month = (m == 12) ? 1 : m+1
      result = get_json("https://api.doorkeeper.jp/events/?locale=ja&sort=starts_at&since=#{y}-#{m}-01&until=#{year}-#{month}-01&q=#{word}")
      puts "Doorkeeper #{result.length}"
      infos = []
      result.each do |row|
        vals = row["event"]
        infos << {
          "title" => vals["title"],
          "started_at" => vals["starts_at"],
          "event_url" => vals["public_url"],
          "address"=> vals["address"]
        }
      end
    return infos
    end

  #eventonからの取得
    # def eventon(ym, word)
    #   result = get_json("https://eventon.jp/api/events.json?keyword=#{word}&ym=#{ym}&limit=100")
    #   puts "eventon #{result["count"]}"
    #   infos = []
    #   result["events"].each do |val|
    #     infos << {
    #       "title" => val["title"],
    #       "started_at" => val["started_at"],
    #       "event_url" => val["event_url"],
    #       "address" => val["address"] + " " + val["place"]
    #     }
    #   end
    #   return infos
    # end

  #atndからの取得
    def atnd(ym, word)
      result = get_json("https://api.atnd.org/events/?format=json&keyword=#{word}&ym=#{ym}&count=100")
      puts "ATND #{result["results_returned"]}"
      infos = []
      result["events"].each do |row|
        val = row["event"]
        infos << {
          "title" => val["title"],
          "started_at" => val["started_at"],
          "event_url" => val["event_url"],
          "address" => val["address"] + " " + val["place"]
        }
      end
      return infos
    end

  #zusaarからの取得
    # def zusaar(ym, word)
    #   result = get_json("https://www.zusaar.com/api/event/?ym=#{ym}&count=100&keyword_or=#{word}")
    #   puts "Zusaar #{result["results_returned"]}"
    #   infos = []
    #   result["event"].each do |val|
    #     infos << {
    #       "title" => val["title"],
    #       "started_at" => val["started_at"],
    #       "event_url" => val["event_url"],
    #       "address" => val["address"] + " " + val["place"]
    #     }
    #   end
    #   return infos
    # end

  #取得したデータを集約する
   def get_events(year, month, word)

      ym = sprintf("%04d%02d", year, month)
      puts "[#{ym}]"

      infos = []
      eventonnumber =
      # infos += eventon(ym, word)
      infos += doorkeeper(year, month, word)
      infos += connpass(ym, word)
      infos += atnd(ym, word)
      # infos += zusaar(ym, word)

      puts "Total #{infos.length}"
      return infos
    end
    # @eventonnumber = eventon(2018/5, keyword).length
    @connpassnumber = connpass(2018/5, keyword).length
    @doorkeepernumber = doorkeeper(2018,5, keyword).length
    @atndnumber = atnd(2018/5,keyword).length
    @keyword = keyword
    @events = get_events(2018, 5, keyword)
  end

end
