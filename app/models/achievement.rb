class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :date, type: Date

  # Associations
  belongs_to :schedule
  has_many :completed_tasks

end