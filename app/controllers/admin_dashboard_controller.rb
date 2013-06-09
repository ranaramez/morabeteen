class AdminDashboardController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @activites_count = Activity.count
    authorize! :read, Activity
  end
end