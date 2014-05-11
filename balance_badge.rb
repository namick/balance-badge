require 'RMagick'
require 'sinatra'

def gen_badge(balance)
  badge = Magick::ImageList.new("wayne.png")
  text = Magick::Draw.new
  text.annotate(badge, 0, 0, 0, 80, "#{balance} BTC") do
      self.gravity = Magick::SouthGravity
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
  body(gen_badge(rand(42)))
end
