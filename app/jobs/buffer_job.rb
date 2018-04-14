class BufferJob < ApplicationJob
  private

  def get_profile_ids(service)
    return if ENV['buffer_access_token'].blank? || !Rails.env.production?
    profiles = Rails.cache.fetch('buffer:profiles', expires_in: 1.hour) do
      response = HTTParty.get("https://api.bufferapp.com/1/profiles.json?access_token=#{ENV['buffer_access_token']}")
      if response.code >= 400
        raise response.body
      else
        response.body
      end
    end
    profiles = JSON.parse(profiles)
    profiles.select { |profile| profile['service'].downcase.match(service) }.map { |profile| profile['id'] }
  end

  def post_to_buffer(profile_ids, text, media = nil)
    body = {
      profile_ids: profile_ids,
      text: text,
      media: media,
      shorten: false,
      access_token: ENV['buffer_access_token']
    }

    body[:media] = media if media.present?

    response = HTTParty.post('https://api.bufferapp.com/1/updates/create.json', body: body)
    if response.code >= 400
      raise JSON.parse(response.body)['message']
    end
  end

  def media_hash(photo, opts = {})
    opts.reverse_merge!(w: 2048, alt_text: false)
    media = {
      photo: photo.url(w: opts[:w], fm: 'jpg'),
      thumbnail: photo.url(w: 512, fm: 'jpg')
    }
    media[:alt_text] = photo.alt_text if opts[:alt_text] && photo.alt_text.present?
    media
  end
end
