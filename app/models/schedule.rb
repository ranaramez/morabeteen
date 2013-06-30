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
  belongs_to :level, dependent: :destroy
  
  accepts_nested_attributes_for :tasks, allow_destroy: true, reject_if: ->(attrs){empty_task?(attrs)}

  # Scopes
  scope :zone, ->(zone){ where(zone: zone)}
  scope :for, ->(date){ where(start_date: date)}
  scope :for_range, ->(date){where(:start_date.lte => date, :end_date.gte => date)}
  scope :within, ->(date){ where(start_date:(date.prev_month..date))}
  scope :with_start_and_end, ->(start, end_date){where(start_date: start, end_date: end_date)}

  # Callbacks
  before_destroy :check_if_can_destroy
  after_create :notify_users_delayed, :set_stats_delayed_job


  # Extensions
  slug :title

  def self.update_multiple_schedules(schedules, params)
    updated = true
    schedules.each do |schedule|
      updated &= schedule.update_attributes(params[schedule.id.to_s])
    end
    updated
  end

  def self.empty_task?(attrs)
    attrs[:description].empty?
  end

  def self.notify_users(schedule_id)
    schedule = Schedule.find(schedule_id)
    users = User.send(schedule.zone.to_s.pluralize.to_sym)
    UserMailer.schedule_started(users, schedule).deliver
  end

  def self.calculate_stats(schedule_id)
    schedule = Schedule.find(schedule_id)
    User.calculate_achievements_stats(schedule.zone)
  end

  protected

  def check_if_can_destroy
    return false if self.start_date < Date.today 
  end

  def notify_users_delayed
    run_at = self.start_date < Date.today ? Time.now : self.start_date.to_datetime
    Schedule.delay(queue: "schedules", run_at: run_at).notify_users(self.id)
  end

  def set_stats_delayed_job
    Schedule.delay(queue: "stats", run_at: self.end_date.to_datetime).calculate_stats(self.id)
  end

  
end