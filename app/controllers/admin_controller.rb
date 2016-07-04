class AdminController < ApplicationController
  layout 'admin'
  before_action :block_cloudfront
  before_action :no_cache
  before_action :require_login
  skip_before_action :domain_redirect

  def index
    redirect_to admin_entries_path
  end
end
