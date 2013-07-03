class UserLevel
  include Mongoid::Document

  field :start_date, type: Date
  field :end_date, type: Date
  field :score, type: Float

  belongs_to :level
  belongs_to :user

  validates_presence_of :start_date, :end_date

  scope :for_date, ->(date){where(:start_date.lte => date, :end_date.gte => date)}

end