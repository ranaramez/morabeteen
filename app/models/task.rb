class Task
  include Mongoid::Document

  # Fields
  field :description
  field :points, type: Integer

  # Associations
  belongs_to :schedule
  belongs_to :activity

  # Validations
  validates_presence_of :description, :points, :schedule, :activity
  validates :points, numericality: {greater_than: 0}

end