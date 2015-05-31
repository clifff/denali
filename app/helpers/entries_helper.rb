module EntriesHelper
  def aperture(f_number)
    "%g" % ("%.2f" % f_number)
  end

  def exposure(exposure)
    exposure = exposure.to_r
    exposure >= 1 ? "%g" % ("%.2f" % exposure) : exposure
  end

  def film(make, model)
    model.match(make) ? model : "#{make} #{model}"
  end

  def camera(make, model)
    make = if make =~ /olympus/i
      'Olympus'
    elsif make =~ /nikon/i
      'Nikon'
    elsif make =~ /fuji/i
      'Fujifilm'
    elsif make =~ /canon/i
      'Canon'
    end
    "#{make} #{model.gsub(%r{#{make}}i, '')}"
  end
end
