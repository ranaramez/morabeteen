module SchedulesHelper

  def total_schedule_points(schedule)
    sum = 0
    schedule.tasks.each { |t| sum += t.points}
    sum
  end

  def can_edit_schedule?(schedule)
    can_edit_start_date?(schedule) || can_extend_end_date?(schedule)
  end

  def can_edit_start_date?(schedule)
    schedule.start_date > Date.today
  end

  def can_extend_end_date?(schedule)
    schedule.end_date >= Date.today
  end
end