class Admin::LensesController < AdminController
  def index
    @lenses = Lens.order('make asc, model asc')
    @page_title = 'Lenses'
  end

  def edit
    @lens = Lens.find(params[:id])
    @page_title = 'Editing lens'
  end

  def update
    @lens = Lens.find(params[:id])
    respond_to do |format|
      if @lens.update(lens_params)
        @lens.photos.map { |p| p.entry.update_tags }
        format.html {
          flash[:success] = 'Your changes were saved!'
          redirect_to admin_lenses_path
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
  def lens_params
    params.require(:lens).permit(:make, :model, :display_name)
  end
end