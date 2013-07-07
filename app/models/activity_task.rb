class ActivityTask 
  include Mongoid::Document

  belongs_to :activity
  belongs_to :schedule, inverse_of: :activity_tasks
  has_many :tasks

  accepts_nested_attributes_for :tasks, allow_destroy: true, reject_if: ->(attrs){empty_task?(attrs)}

  def self.empty_task?(attrs)
    attrs[:description].empty?
  end

  def total_points
    self.tasks.sum(:points)
  end

end