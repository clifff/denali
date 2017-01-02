class MapsController < ApplicationController
  before_action :set_max_age, only: [:index, :photos]
  before_action :set_entry_max_age, only: [:photo]

  layout false

  def index
  end

  def photos
    if stale?(@photoblog, public: true)
      respond_to do |format|
        format.json
      end
    end
  end

  def photo
    @photo = Photo.joins(:entry).where(photos: { id: params[:id] }, entries: { status: 'published' }).limit(1).first
    raise ActiveRecord::RecordNotFound if @photo.nil?
    if stale?(@photo, public: true)
      respond_to do |format|
        format.json
      end
    end
  end
end
