module FollowUpActivityMessagesHelper

  def involved_activities(level)
    level.schedules.map{|s| s.tasks.map(&:activity)}.flatten.uniq.map{ |a| [a.title, a.id]}
  end
end