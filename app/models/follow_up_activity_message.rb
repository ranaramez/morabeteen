class FollowUpActivityMessage
  include Mongoid::Document

  field :message
  field :start_range, type: Integer
  field :end_range,   type: Integer

  belongs_to :level
  belongs_to :activity

  validates_numericality_of :start_range, :end_range, greater_than_or_equal_to: 0, less_than_or_equal_to: 100,
                            only_integer: true
  validates_presence_of :start_range, :end_range, :message
  validate :start_range_less_than_end_range, if: ->{start_range >= end_range}

  def start_range_less_than_end_range
    errors.add(:start_range, I18n.t('mongoid.errors.models.follow_up_activity_message.attributes.start_range.start_range_less_than_end_range'))
  end

end