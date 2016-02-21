json.cache! "entries/json/page/#{@page}/count/#{@count}/#{@photoblog.id}/#{@photoblog.updated_at.to_i}" do
  json.entries @entries do |e|
    json.cache! "entry/json/#{e.id}/#{e.updated_at.to_i}" do
      json.(e, :title)
      json.url e.permalink_url
      json.photos e.photos do |p|
        json.url p.original_url
        json.crop p.crop || 'center'
      end
    end
  end
end
