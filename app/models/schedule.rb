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
  belongs_to :level

  accepts_nested_attributes_for :tasks, allow_destroy: true, reject_if: ->(attrs){empty_task?(attrs)}

  # Scopes
  scope :zone, ->(zone){ where(zone: zone)}
  scope :for, ->(date){ where(start_date: date)}
  scope :for_range, ->(date){where(:start_date.lte => date, :end_date.gte => date)}
  scope :within, ->(date){ where(start_date:(date.prev_month..date))}
  scope :with_start_and_end, ->(start, end_date){where(start_date: start, end_date: end_date)}
  scope :ended, ->{ where(:end_date.lt => Date.today) }

  # Callbacks
  before_destroy :check_if_can_destroy
  after_destroy :clear_level_if_last
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

  def self.calculate_winners(schedule_id)
    schedule = Schedule.find(schedule_id)
    users_to_notify = User.calculate_general_achievements_stats(schedule.zone, schedule.start_date, schedule.end_date)
    users_to_notify.keys.each_with_index do |user, rank|
      UserMailer.notify_winner(user, rank+1, schedule).deliver
    end
  end

  def self.automated_follow_up(schedule_id)
  end

  def self.last_schedule(zone)
    Schedule.zone(zone).ended.desc(&:start_date).first
  end

  def check_if_can_destroy
    self.start_date < Date.today ? false : true
  end

  def ended?
    self.end_date < Date.today
  end

  protected

  def clear_level_if_last
    self.level.destroy unless self.level.schedules.present?
  end

  def notify_users_delayed
    run_at = self.start_date < Date.today ? Time.now : self.start_date.to_datetime
    Schedule.delay(queue: "schedules", run_at: run_at).notify_users(self.id)
  end

  def set_stats_delayed_job
    Schedule.delay(queue: "winners", run_at: (self.end_date + 1).to_datetime.change(hour: 12)).calculate_winners(self.id)
  end


end
