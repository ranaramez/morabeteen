class Task
  include Mongoid::Document

  # Fields
  field :description
  field :points, type: Integer

  # Validations
  validates_presence_of :description, :points
  validates :points, numericality: {greater_than: 0}

  # Associations
  embedded_in :schedule
end