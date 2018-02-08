class PaletteJob < ApplicationJob
  queue_as :default

  def perform(photo)
    palette = request_palette(photo)
    photo.color_vibrant = palette.dig('dominant_colors', 'vibrant', 'hex')
    photo.color_muted   = palette.dig('dominant_colors', 'muted', 'hex')
    photo.color_palette = palette['colors'].map { |c| c['hex'] }.join(',')
    photo.thumbnail = Base64.strict_encode64(HTTParty.get(photo.url(w: 10, auto: 'compress')).body)
    photo.save
  end

  private
  def request_palette(photo)
    request = HTTParty.get(photo.palette_url)
    JSON.parse(request.body)
  end
end