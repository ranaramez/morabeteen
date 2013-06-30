class FollowUpActivityMessage
  include Mongoid::Document

  field :message
  field :start_range, type: Integer
  field :end_range,   type: Integer

  belongs_to :level

end