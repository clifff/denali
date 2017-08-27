json.set! '@context', 'http://schema.org'
json.set! '@type', 'BlogPosting'
json.set! 'mainEntityOfPage' do
  json.set! '@type', 'WebPage'
  json.set! '@id', entry.permalink_url
end
json.headline entry.plain_title
json.description meta_description(entry)
json.set! 'datePublished', entry.published_at
json.set! 'dateModified', entry.updated_at
if entry.is_photo?
  json.image do
    json.set! '@type', 'ImageObject'
    json.url entry.photos.first.url(w: 1392, fm: 'jpg')
    json.width 1392
    json.height entry.photos.first.height_from_width(1392)
  end
end
json.author do
  json.set! '@type', 'Person'
  json.name entry.user.name
end
json.publisher do
  json.set! '@type', 'Organization'
  json.name @photoblog.name
  if @photoblog.logo.present?
    json.logo do
      json.set! '@type', 'ImageObject'
      json.width 145
      json.height 60
      json.url @photoblog.logo_url(w: 145, h: 60, fm: 'png', pad: 6, fit: 'fill', bg: '0fff')
    end
  end
end