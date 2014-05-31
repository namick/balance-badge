require 'net/http'
require 'json'
require 'RMagick'
require 'sinatra'
require 'chain'

SATOSHI = 1
BTC = SATOSHI * 100_000_000

def get_balance(addr_hash)
  a = Chain.get_address(addr_hash)
  a.nil? ? 0 : Integer(a["balance"]) / Float(BTC)
end

def gen_badge(balance)
  badge = Magick::ImageList.new("badge-v2-400.png")
  text = Magick::Draw.new
  text.annotate(badge, 0, 0, 0, 60, "#{balance.round(2)}") do
      self.font_family = 'Helvetica'
      self.gravity = Magick::NorthGravity
      self.pointsize = 80
      self.stroke = 'transparent'
      self.fill = '#00a4c8'
      self.font_weight = Magick::LighterWeight
  end
  badge.format = 'png'
  badge.to_blob {self.quality = 80}
end

get '/bitcoin/balance/:addr_hash' do
  content_type 'image/png'
  status(200)
  addr_hash = params['addr_hash']
  addr_hash.gsub!('.png', '')
  body(gen_badge(get_balance(addr_hash)))
end
