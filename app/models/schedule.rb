class Schedule
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  # Constants
  ZONES = [:male, :female]

  # Fields
  field :title
  field :start_date, type: Date
  field :end_date, type: Date
  field :zone, type: Symbol

  # Associations
  has_many :tasks
  

  accepts_nested_attributes_for :tasks

  # Extensions
  slug :title
end