module UsersHelper
  
  def get_schedule(date, schedules)
    schedules.collect { |c| c if c.start_date <= date && c.end_date >= date}.compact
  end

  def schedules_select(schedules, f, date, completed_tasks)
    options = []
    schedules.each do |schedule|
      partial = render(partial: 'users/schedule', locals: {f: f, schedule: schedule, date: date, completed_tasks: completed_tasks})
      options << [schedule.title, schedule.id, {:'data-partial' => partial.gsub("\n", "")}]
    end
    options
  end

  def check_completed(task, date, completed_tasks)
    completed_tasks.try(:include?, task) || false
  end

  def day_score(date)
    current_user.achievements.for(date).try(:first).try(:total_score) || 0
  end

  def get_selected(schedules, selected)
    return schedules.find(selected) if selected.present?
    return schedules.first
  end

  def total_acc_score
    current_user.total_points(@achievements)
  end

  def total_week_score(start_date, end_date)
    current_user.total_points(@achievements, start_date, end_date)
  end
end