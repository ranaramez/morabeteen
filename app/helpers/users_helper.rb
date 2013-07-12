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
    current_user.achievements.for(date).map{ |a| a.total_score }.flatten.inject(0, :+)
  end

  def get_selected(schedules, selected)
    return schedules.select{|s| s==selected}.first if selected.present?
    return schedules.first
  end

  def total_acc_score
    current_user.total_points(@achievements)
  end

  def total_week_score(start_date, end_date)
    current_user.total_points(@achievements, start_date, end_date)
  end

  def level_select(levels)
    options = []
    levels.each do |level|
      options << [level.name, level.id]
    end
    options
  end

  def ended_schedules?(schedules)
    schedules.first.ended?
  end

  def current_level(date)
    current_user.level(date)
  end

  def missed_schedule?(start_date, end_date)
    current_user.achievements.for_range(start_date, end_date).empty? && end_date < Date.today
  end

  def show_level_select?(start_date, end_date, schedules)
    ended_schedules?(schedules) || current_user.level(start_date).present?
  end

  def level_schedules(schedules, user_level)
    if user_level
      schedules.keep_if{|s| s.level == user_level}
    else
      schedules
    end
  end

  def get_selected_schedule_for_date(date)
    @achievements.for(date).desc(:updated_at).try(:first).try(:schedule)
  end
end