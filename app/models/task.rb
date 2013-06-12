class Task
  include Mongoid::Document

  # Fields
  field :description
  field :points, type: Integer

  attr_accessor :common

  # Associations
  has_and_belongs_to_many :schedules, inverse_of: :tasks
  belongs_to :activity

  # has_and_belongs_to_many :common_schedules, class_name: "Schedule", inverse_of: :common_tasks

  # Validations
  validates_presence_of :description, :points, :schedules, :activity
  validates :points, numericality: {greater_than: 0}

  # Callbacks
  before_save :handle_common


  private

  def handle_common
    if self.common.present? && self.common == "1"
      schedules = Schedule.zone(self.schedules.first.zone).for(self.schedules.first.start_date) - self.schedules
      self.schedules.push(schedules)
    end
  end

end