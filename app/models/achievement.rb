class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :date, type: Date

  # Associations
  belongs_to :user
  has_and_belongs_to_many :completed_tasks, class_name: 'Task', inverse_of: nil

  # Attr 
  attr_accessor :unchecked_task
  attr_accessor :schedule_id

  # Scopes
  scope :for, ->(date) { where(date: date)}
  scope :for_range, ->(start_range, end_range) { where(date:(start_range..end_range))}

  def total_score
    self.completed_tasks.sum(:points)
  end

end