class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :date, type: Date

  # Associations
  belongs_to :user
  has_and_belongs_to_many :completed_tasks, class_name: 'Task', inverse_of: nil, after_add: :assing_level, after_remove: :unassign_level
  belongs_to :schedule

  # Attr 
  attr_accessor :unchecked_task

  # Scopes
  scope :for, ->(date) { where(date: date)}
  scope :for_users, ->(users){where(:user.in => users)}
  scope :for_range, ->(start_range, end_range) { between(date: start_range..end_range)}
  scope :with_level, ->{where(:level.ne => nil)}

  after_create ->{self.assing_level(completed_tasks.first)}

  validates_presence_of :date, :user

  def total_score
    self.completed_tasks.sum(:points)
  end

  def self.calculate_activity_score(achievements, activity)
    result = 0
    achievements.each do |a|
      result += a.completed_tasks.for_activity(activity).sum(:points)
    end
    result
  end

  def self.total_score(achievements)
    score = 0
    achievements.each{ |a| score += a.completed_tasks.sum(:points) }
    score
  end

  protected

  def assing_level(e)
    unless self.user.level(self.date)
      schedule = e.activity_task.schedule
      user_level = self.user.levels.create(start_date: schedule.start_date, end_date: schedule.end_date, level: schedule.level)
    end
    user_level
  end

  def unassign_level(e)
    completed_tasks = self.completed_tasks - [e]
    self.user.level(self.date).destroy && self.destroy if completed_tasks.empty? && self.user.level(self.date)
  end

end