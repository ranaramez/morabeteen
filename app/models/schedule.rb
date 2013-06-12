class Schedule
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  include Mongoid::Slug

  # Constants
  ZONES = [:male, :female]

  # Fields
  field :title
  field :start_date, type: Date
  field :end_date, type: Date
  field :zone, type: Symbol

  # Associations
  has_and_belongs_to_many :tasks, inverse_of: :schedules, dependent: :destroy
  # belongs_to :creator, class_name: 'User'
  
  accepts_nested_attributes_for :tasks, allow_destroy: true, autobuild: true, reject_if: :all_blank

  # Scopes
  scope :zone, ->(zone){ where(zone: zone)}
  scope :for, ->(date){ where(start_date: date)}

  # Callbacks
  before_destroy :check_if_can_destroy


  # Extensions
  slug :title

  def self.update_multiple_schedules(schedules, params)
    updated = true
    schedules.each do |schedule|
      updated &= schedule.update_attributes(params[schedule.id.to_s])
    end
    updated
  end

  protected

  def check_if_can_destroy
    return false if self.start_date < Date.today 
  end
end