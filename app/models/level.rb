class Level
  include Mongoid::Document

  field :name

  attr_accessor :start_date, :end_date

  has_many :schedules

  accepts_nested_attributes_for :schedules

  before_create :assign_schedule_dates

  private

  def assign_schedule_dates
    self.schedules.each { |s| s.start_date = start_date; s.end_date = end_date}
  end
end