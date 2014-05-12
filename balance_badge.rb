require 'net/http'
require 'json'
require 'RMagick'
require 'sinatra'

SATOSHI = 1
BTC = SATOSHI * 100_000_000

CHAIN_URL = URI.parse(ENV['CHAIN_URL'])

def get_balance(addr_hash)
  puts addr_hash
  path = "/bitcoin/addresses/#{addr_hash}"
  con = Net::HTTP.new(CHAIN_URL.host, CHAIN_URL.port)
  req = Net::HTTP::Get.new(CHAIN_URL.request_uri + path)
  req.basic_auth(CHAIN_URL.user, '')
  resp = con.request(req)
  return 0 if (Integer(resp.code) / 100) != 2
  begin
    json = JSON.parse(resp.body)
    return Integer(json["balance"]) / Float(BTC)
  rescue
    return 0
  end
end

def gen_badge(balance)
  badge = Magick::ImageList.new("badge.png")
  text = Magick::Draw.new
  text.annotate(badge, 0, 0, 0, 80, "#{balance} BTC") do
      self.gravity = Magick::CenterGravity
      self.pointsize = 50
      self.stroke = 'transparent'
      self.fill = '#fff'
      self.font_weight = Magick::BoldWeight
  end
  badge.format = 'png'
  badge.to_blob {self.quality = 80}
end

get '/address/:addr_hash' do
  content_type 'image/png'
  status(200)
  addr_hash = params['addr_hash']
  addr_hash.gsub!('.png', '')
  body(gen_badge(get_balance(addr_hash)))
end
