class PhotoGeocodeJob < ApplicationJob
  queue_as :default

  def perform(photo)
    return if ENV['google_api_key'].blank? || !photo.has_location?
    url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{photo.latitude},#{photo.longitude}&key=#{ENV['google_api_key']}"
    response = JSON.parse(HTTParty.get(url).body)
    if response['status'] != 'OK'
      logger.tagged('Google Maps') { logger.error response.to_s }
    else
      result = response['results'][0]
      components = result['address_components']

      photo.country             = components.select { |c| c['types'].include? 'country' }.map {|c| c['long_name']}.join(', ')
      photo.locality            = components.select { |c| c['types'].include? 'locality' }.map {|c| c['long_name']}.join(', ')
      photo.sublocality         = components.select { |c| c['types'].include? 'sublocality' }.map {|c| c['long_name']}.join(', ')
      photo.neighborhood        = components.select { |c| c['types'].include? 'neighborhood' }.map {|c| c['long_name']}.join(', ')
      photo.administrative_area = components.select { |c| c['types'].include? 'administrative_area_level_1' }.map {|c| c['long_name']}.join(', ')
      photo.postal_code         = components.select { |c| c['types'].include? 'postal_code' }.map {|c| c['long_name']}.join(', ')
      photo.save
    end
  end
end
