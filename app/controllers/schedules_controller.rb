class SchedulesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html, :js

  def index
    @schedules = @schedules.desc(:created_at).zone(current_user.gender)
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
    respond_with @schedule, location: schedules_path
  end

  def edit_multiple
    @schedules = Schedule.zone(current_user.gender).for(@schedule.start_date)
    @start_date = @schedule.start_date
    @end_date = @schedule.end_date
  end

  def update_multiple
    start_date = *params[:start_date].values_at(:year, :month, :day).map{|c| c.to_i}
    end_date = *params[:end_date].values_at(:year, :month, :day).map{|c| c.to_i}
    @schedules = Schedule.zone(current_user.gender).with_start_and_end(params[:prev_start_date].to_date, params[:prev_end_date].to_date)
    if @schedules.update_all(start_date: start_date, end_date: end_date)
      flash[:notice] = "Successfully updated schedules date."
    end 
    respond_with @schedules, location: schedules_path
  end


  def create_multiple
    start_date = *params[:start_date].values_at(:year, :month, :day).map{|c| c.to_i}
    end_date = *params[:end_date].values_at(:year, :month, :day).map{|c| c.to_i}
    values = params[:levels].values.each { |v| v.merge!(start_date: start_date, end_date: end_date)}
    if @levels = Level.create(values)
      flash[:notice] = "Successfully created schedules"
    end
    respond_with @schedules, location: schedules_path
  end
end