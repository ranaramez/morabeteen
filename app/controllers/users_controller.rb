class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html, :js

  def show
    @schedules = current_user.schedules(Date.today).asc(:start_date)
  end

  def update_achievement

  end
end