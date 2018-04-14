module ApplicationHelper

  def responsive_image_tag(photo, photo_key, html_options = {})
    html_options[:srcset] = get_srcset(photo, photo_key)
    html_options[:sizes] = get_sizes(photo_key)
    html_options[:src] = get_src(photo, photo_key) unless PHOTOS[photo_key]['src'].nil?
    content_tag :img, nil, html_options
  end

  def lazy_responsive_image_tag(photo, photo_key, html_options = {})
    html_options[:'data-srcset'] = get_srcset(photo, photo_key)
    html_options[:sizes] = get_sizes(photo_key)
    html_options[:'data-src'] = get_src(photo, photo_key) unless PHOTOS[photo_key]['src'].nil?
    html_options[:src] = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'
    content_tag :img, '', html_options
  end

  def get_src(photo, photo_key)
    quality = PHOTOS[photo_key]['quality']
    square = PHOTOS[photo_key]['square'].present?
    width = PHOTOS[photo_key]['src']
    client_hints = PHOTOS[photo_key]['client_hints']
    auto = PHOTOS[photo_key]['auto'] || 'format'
    photo.url(w: width, q: quality, square: square, ch: client_hints, auto: auto)
  end

  def get_srcset(photo, photo_key)
    quality = PHOTOS[photo_key]['quality']
    square = PHOTOS[photo_key]['square'].present?
    client_hints = PHOTOS[photo_key]['client_hints']
    auto = PHOTOS[photo_key]['auto'] || 'format'
    PHOTOS[photo_key]['srcset'].
      uniq.
      sort.
      reject { |width| width > photo.width }.
      map { |width| "#{photo.url(w: width, q: quality, square: square, ch: client_hints, auto: auto)} #{width}w" }.
      join(', ')
  end

  def get_sizes(photo_key)
    PHOTOS[photo_key]['sizes'].join(', ')
  end

  def inline_svg(icon, svg_class = "icon")
    render partial: "partials/svg/#{icon}.html.erb", locals: { svg_class: "#{svg_class} #{svg_class}--#{icon}" }
  end

  def intrinsic_ratio_padding(photo, opts = {})
    opts.reverse_merge!(square: false)
    padding = opts[:square] ? 100 : ((photo.height.to_f/photo.width.to_f) * 100)
    "padding-top:#{padding}%"
  end

  def intrinsic_ratio_width(photo)
    width = (photo.width.to_f/photo.height.to_f) * 100
    "width:#{width}vh"
  end

  def image_placeholder(photo)
    return '' if photo.color_palette.blank?
    style = if photo.color_palette.present?
      palette = photo.color_palette.split(',').sample(2).join(',')
      "background:linear-gradient(to bottom right, #{palette})"
    end
    style.html_safe
  end

  def inline_asset(filename, opts = {})
    opts.reverse_merge!(strip_charset: false)
    if opts[:strip_charset]
      Rails.application.assets[filename].to_s.gsub('@charset "UTF-8";', '').html_safe
    else
      Rails.application.assets[filename].to_s.html_safe
    end
  end
end
