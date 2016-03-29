class SessionsController < ApplicationController
  skip_before_action :domain_redirect
  before_action :block_cloudfront
  def new
    render
  end

  def create
    auth_hash = request.env['omniauth.auth']
    email = auth_hash.try(:[], 'info').try(:[], 'email')

    if email == Rails.application.config.site['auth_email']
      flash[:notice] = "Welcome, #{auth_hash['info']['name']}!"
      user = User.from_omniauth(env['omniauth.auth'])
      session[:user_id] = user.id
      url = session[:original_url] || admin_entries_path
      session[:original_url] = nil
      logger.info "[INFO] Successful login by #{email}"
      redirect_to url
    else
      logger.info "[INFO] Unsuccessful login by #{email}"
      redirect_to signin_path, alert: 'There was a problem logging you in.'
    end
  end

  def failure
    redirect_to signin_path, alert: "There was a problem logging you in: #{params[:message]}."
  end

  def destroy
    session[:current_user] = nil
    redirect_to signin_path, notice: 'You have been logged out.'
  end
end
