require 'net/http'
require 'uri'
require 'json'
require 'date'

class CoinstudyController < ApplicationController

  def index

    # keyword = params[:keyword]
    keyword1 = "blockchain"
    keyword2 = "仮想通貨"
    date = params[:date]
    now = Time.now

    def get_json(url)
      uri = URI.parse(URI.escape(url))
      json = Net::HTTP.get(uri)
      result = JSON.parse(json)
    end

  #connpassからの取得
    def connpass(word1,word2,ym)
      result = get_json("https://connpass.com/api/v1/event/?keyword_or=#{word1}&keyword_or=#{word2}&ym=#{ym}&order=2&count=100")

      puts "connpass #{result["results_available"]}, #{result["results_returned"]}"

      infos = []

      result["events"].each do |val|
        infos << {
          "title" => val["title"],
          "started_at" => val["started_at"],
          "event_url" => val["event_url"],
          "address" => val["address"],
          "description" => val["description"]
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

  #取得したデータを集約する
   def get_events(year, month, word1,word2)

      ym = sprintf("%04d%02d", year, month)
      puts "[#{ym}]"

      infos = []
      eventonnumber =
      infos += doorkeeper(year, month, word1)
      infos += connpass(ym, word1,word2)

      puts "Total #{infos.length}"
      return infos
    end

    if date.blank?
      @now = now
    else
      @now = date
    end
# 選択されたものを→ date型にする
    s = @now.to_time
# sを→string型にする
    t = s.to_s
# 西暦と月を出す
    y = t.split("/")
    selected_year = y[0].to_i
    selected_month = y[1].to_i

    if date.blank?
      @now = now
    else
      @now = y[0]
    end

    # @keyword = keyword
    @events = Kaminari.paginate_array(get_events(selected_year, selected_month, keyword1,keyword2)).page(params[:page]).per(10)
  end

end

def about
  render 'About'
end
