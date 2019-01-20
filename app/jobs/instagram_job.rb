class InstagramJob < BufferJob
  queue_as :default

  def perform(entry)
    return if !entry.is_photo?
    text = entry.instagram_caption
    media = media_hash(entry.photos.first)
    post_to_buffer('instagram', text: text, media: media, scheduled_at: 2.hours.from_now.to_i)
  end

  private
  def media_hash(photo)
    {
      photo: photo.instagram_url,
      thumbnail: photo.url(w: 512, fm: 'jpg')
    }
 end
end
