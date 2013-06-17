module UsersHelper
  
  def get_schedule(date, schedules)
    schedules.collect { |c| c if c.start_date <= date && c.end_date >= date}
  end

  def schedules_select(schedules, f)
    options = []
    schedules.each do |schedule|
      partial = render(partial: 'users/schedule', locals: {f: f, schedule: schedule})
      options << [schedule.title, schedule.id, {:'data-partial' => partial.gsub("\n", "")}]
    end
    options
  end
end