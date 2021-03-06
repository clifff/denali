namespace :exif do
  desc "Refreshes exif data for entries"
  task :update => :environment do
    if ENV['ENTRY_ID'].present?
      entry = Entry.find(ENV['ENTRY_ID'])
      if entry.present?
        entry.photos.each do |p|
          PhotoMetadataJob.perform_later(p, { geocode: false })
        end
      end
    else
      puts 'Please specify `ENTRY_ID`.'
    end
  end

  desc "Refreshes exif data for all entries"
  task :update_all => :environment do
    Photo.find_each do |p|
      PhotoMetadataJob.perform_later(p, { geocode: false })
    end
  end
end
