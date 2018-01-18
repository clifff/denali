class TwitterJob < BufferJob
  queue_as :default

  def perform(entry)
    max_length = 230 # 280 characters - 25 for the image url - 25 for the permalink url
    caption = entry.tweet_text.present? ? entry.tweet_text : entry.plain_title
    text = "#{truncate(caption, length: max_length, omission: '…')} #{entry.permalink_url}"

    ids = get_profile_ids('twitter')
    media = media_hash(entry.photos.first)
    post_to_buffer(ids, text, media)
  end
end
