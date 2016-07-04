class MapsController < ApplicationController
  layout false

  def index
    expires_in 24.hours, public: true
    fresh_when @photoblog, public: true
  end

  def photos
    expires_in 24.hours, public: true
    @entries = @photoblog.entries.mapped
    if stale?(@photoblog, public: true)
      respond_to do |format|
        format.json
      end
    end
  end
end
