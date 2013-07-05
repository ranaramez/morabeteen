class Level
  include Mongoid::Document

  field :name
  field :default, type: Boolean, default: false
  field :rank, type: Integer, default: 0

  attr_accessor :start_date, :end_date

  has_many :schedules
  has_many :follow_up_activity_messages
  has_many :users, class_name: "UserLevel", inverse_of: :level

  accepts_nested_attributes_for :schedules, :follow_up_activity_messages

  before_create :assign_schedule_dates
  before_save :clear_all_defaults, if: :default

  validates_presence_of :name, :rank

  private

  def assign_schedule_dates
    self.schedules.each { |s| s.start_date = start_date; s.end_date = end_date}
  end

  def clear_all_defaults
    Schedule.zone(self.schedules.first.zone).for(self.schedules.first.start_date).map(&:level).each do |level|
      level.update_attribute(:default, false) if level.default
    end
  end
end