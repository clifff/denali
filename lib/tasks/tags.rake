namespace :tags do
  namespace :update do
    task :equipment => [:environment] do
      Entry.find_each do |e|
        tags = []
        e.photos.each do |p|
          tags << p.formatted_camera
          tags << p.formatted_film if p.film_make.present? && p.film_type.present?
        end
        e.equipment_list.add(tags)
        e.save
      end
    end

    task :locations => [:environment] do
      Entry.find_each do |e|
        ReverseGeocodeJob.perform_later(e) if e.show_in_map?
      end
    end
  end

  namespace :clear do
    task :equipment => [:environment] do
      Entry.find_each do |e|
        e.equipment_list = []
        e.save
      end
    end

    task :locations => [:environment] do
      Entry.find_each do |e|
        e.location_list = []
        e.save
      end
    end
  end

  task :cleanup => [:environment] do
    Entry.find_each do |e|
      e.tag_list.remove(e.equipment_list)
      e.tag_list.remove(e.location_list)
      e.save
    end
  end
end
