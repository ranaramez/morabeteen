class SchedulesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html, :js

  def index
    @scedules = @schedules.zone(current_user.gender)
    num_of_records = @zone.to_sym == :female ? 2 : 1
    @new_schedules = Array.new(num_of_records) {Schedule.new} 
  end

  def show
  end

  def edit
  end

  def update
    if @schedule.update_attributes params[:schedule]
      flash[:notice] = "Successfully updated schedule"
    end
    respond_with @schedule
  end

  def new
    num_of_records = @zone.to_sym == :female ? 2 : 1
    @schedules = Array.new(num_of_records) {Schedule.new}
  end

  def create
    @schedule = Schedule.new params[:schedule]
    if @schedule.save
      flash[:notice] = "Successfully created schedule"
    end
    respond_with @schedule
  end

  def destroy
    if @schedule.destroy
      flash[:notice] = "Successfully deleted schedule"
    end
    respond_with @schedule
  end

  def edit_multiple
    @schedules = Schedule.zone(current_user.gender).for(@schedule.start_date)
  end

  def update_multiple
    start_date = *params[:start_date].values_at(:year, :month, :day).map{|c| c.to_i}
    end_date = *params[:end_date].values_at(:year, :month, :day).map{|c| c.to_i}
    @schedules = Schedule.find(params[:schedules].keys)
    values = params[:schedules].each { |s| s[1].merge!(zone: @zone, start_date: start_date, end_date: end_date)}
    if Schedule.update_multiple_schedules(@schedules, values)
      flash[:notice] = "Successfully updated schedules."
    end
    respond_with @schedules, location: edit_multiple_schedule_path(@schedules.first)
  end


  def create_multiple
    start_date = *params[:start_date].values_at(:year, :month, :day).map{|c| c.to_i}
    end_date = *params[:end_date].values_at(:year, :month, :day).map{|c| c.to_i}
    values = params[:schedules].values.each { |v| v.merge!(zone: @zone, start_date: start_date, end_date: end_date)}
    if @schedules = Schedule.create(values)
      flash[:notice] = "Successfully created schedule"
    end
    respond_with @schedules, location: edit_multiple_schedule_path(@schedules.first)
  end
end