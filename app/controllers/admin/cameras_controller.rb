class Admin::CamerasController < AdminController
  def index
    @cameras = Camera.order('make asc, model asc')
    @page_title = 'Cameras'
  end

  def edit
    @camera = Camera.find(params[:id])
    @page_title = 'Editing camera'
  end

  def update
    @camera = Camera.find(params[:id])
    respond_to do |format|
      if @camera.update(camera_params)
        @camera.photos.map { |p| p.entry.update_tags }
        format.html {
          flash[:success] = 'Your changes were saved!'
          redirect_to admin_cameras_path
        }
      else
        format.html {
          flash[:warning] = 'Your changes couldn’t be saved…'
          render :edit
        }
      end
    end
  end

  private
  def camera_params
    params.require(:camera).permit(:make, :model, :display_name, :is_phone)
  end
end