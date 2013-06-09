class ActivitiesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html, :js

  def index
    @activities = Activity.all
  end

  def new
    @activity = Activity.new
  end

  def create
    @activity = Activity.new params[:activity]
    if @activity.save
      flash[:notice] = "Successfully created Activity"
    end
    respond_with(@activity, location: activities_url)
  end

  def destroy
    @activity = Activity.find params[:id]
    if @activity.destroy 
      flash[:notice] = "Successfully deleted Activity"
    end
    respond_with(@activity)
  end
end