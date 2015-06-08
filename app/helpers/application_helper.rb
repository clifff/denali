module ApplicationHelper

  def responsive_image_tag(photo, widths = [], sizes = '100vw', image_options = {}, html_options = {})
    image_options.reverse_merge! square: false, quality: 90, default_width: 1280, default_height: 0, upscale: false
    html_options.reverse_merge! alt: photo.plain_caption || photo.entry.title
    html_options[:sizes] = sizes unless sizes == ''
    srcset = []
    if image_options[:square]
      widths.each do |w|
        srcset << "#{photo.url(w, w, image_options[:quality], image_options[:upscale])} #{w}w"
      end
      html_options[:srcset] = srcset.join(', ')
      src = photo.url(image_options[:default_width], image_options[:default_width], image_options[:quality], image_options[:upscale])
    else
      widths.each do |w|
        srcset << "#{photo.url(w, image_options[:default_height], image_options[:quality], image_options[:upscale])} #{w}w"
      end
      html_options[:srcset] = srcset.join(', ')
      src = photo.url(image_options[:default_width], image_options[:default_height], image_options[:quality], image_options[:upscale])
    end
    image_tag src, html_options
  end

  def photo_sizes
    sizes = []
    sizes << [320, 480]          # iPhone
    sizes << [320 * 2, 480 * 2]  # iPhone 4
    sizes << [320 * 2, 568 * 2]  # iPhone 5
    sizes << [375 * 2, 667 * 2]  # iPhone 6
    sizes << [414 * 3, 736 * 3]  # iPhone 6 plus
    sizes << [1024, 768]         # iPad
    sizes << [1024 * 2, 768 * 2] # iPad Air
    sizes << [1280, 1280 * 2]    # Macbook
    sizes << [1440, 1440 * 2]    # Macbook
    sizes << [1920, 1920 * 2]    # iMac
    sizes.flatten.sort.reverse.uniq
  end

  def copyright_years
    if Entry.published.last.nil?
      Time.now.strftime('%Y')
    elsif Entry.published.last.published_at.strftime('%Y') == Time.now.strftime('%Y')
      Time.now.strftime('%Y')
    else
      "#{Entry.published.last.published_at.strftime('%Y')}-#{Time.now.strftime('%Y')}"
    end
  end
end
