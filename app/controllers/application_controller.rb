class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :current_zone

  layout 'application'

  def current_zone
    @zone = current_user.gender if user_signed_in?
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied. #{exception.message}"
    redirect_to root_url
  end
end
