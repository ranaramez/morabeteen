class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html, :js

  def show
    @schedules = current_user.schedules(Date.today).asc(:start_date)
    @completed_tasks = current_user.completed_tasks_by_day
    @achievements = current_user.achievements
  end

  def update_achievement
    removed_task = Task.find(params[:achievement][:unchecked_task]) if params[:achievement][:unchecked_task]
    checked_task = Task.find(params[:achievement][:completed_task_ids]) if params[:achievement][:completed_task_ids]
    if @achievement = current_user.achievements.find_by(date: params[:achievement][:date].to_date)
      unless removed_task
        completed_tasks = [checked_task] - @achievement.completed_tasks
        @achievement.completed_tasks.push(completed_tasks) unless completed_tasks.empty?
      else
        @achievement.completed_tasks.delete(removed_task)
      end
    else
      @achievement = current_user.achievements.create params[:achievement]
    end
    @schedules = Schedule.zone(current_user.gender).for_range(params[:achievement][:date])
    @achievements = current_user.achievements
    @completed_tasks = current_user.completed_tasks_by_day(@achievements)
    @date = params[:achievement][:date]
    @selected_schedule_id = params[:achievement][:schedule_id]
    @total_acc_score = current_user.total_points(@achievements)
    @current_week_score = current_user.total_points(@achievements, @schedules.first.start_date, @schedules.first.end_date)

    @response = {schedules: @schedules, date: @date, schedule_id: @selected_schedule_id, completed_task_ids: @completed_tasks, acc_score: @total_acc_score}
    respond_with @response, location: user_path(current_user)
  end
end