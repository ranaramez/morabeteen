class LeadersController < ApplicationController

  def index
    @schedule = Schedule.last_schedule(@zone)
    if @schedule
      @all_schedule_leaders = User.calculate_general_achievements_stats(@zone, @schedule.start_date, @schedule.end_date)
      @activities_leaders = User.calculate_activities_achievements_stats(@zone, @schedule.start_date, @schedule.end_date)    
    end
  end
  
end
