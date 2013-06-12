class Achievement
  include Mongoid::Document

  # Fields
  field :date, type: Date

  # Associations
  has_many :completed_tasks

  

end