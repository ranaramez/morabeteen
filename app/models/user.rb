class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
        :rememberable, :trackable

  # Constants
  GENDERS = [:male, :female]

  GENDER_PREFIX_CODE = {
    male: "11",
    female: "10"
  }
  ROLES = [:admin, :default]

  ## Database authenticatable
  field :encrypted_password, :type => String, :default => ""
  field :username,            type: String
  # field :email
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  # Fields
  # field :first_name
  # field :last_name
  # field :facebook_uid
  field :gender,             type: Symbol
  # field :code_name,          type: String
  field :role,               type: Symbol

  attr_accessor :choosen_level

  #Extensions
  slug :username
  # mount_uploader :avatar, AvatarUploader
  
  # Relations
  has_many :achievements
  has_many :levels, class_name: "UserLevel", inverse_of: :user
  
  # Validations
  validates_presence_of :gender
  validates_presence_of   :password, :on=>:create
  validates_confirmation_of   :password, :on=>:create
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true
  # check on format no whitespaces
  validates :username, :uniqueness => { :case_sensitive => false}

  # Callbacks
  # before_create :generate_code
  # before_create :skip_confirmation_mail, if: ->{self.facebook_uid.present?}
  # before_create :skip_confirmation_mail


  scope :females, where(gender: :female)
  scope :males, where(gender: :male)
  # Methods
  def name
    "#{first_name} #{last_name}"
  end

  # def email_required?
  #   false
  # end

  # def self.find_first_by_auth_conditions(warden_conditions)
  #   conditions = warden_conditions.dup
  #   if username = conditions.delete(:username)
  #     self.where(username: /^#{Regexp.escape(login)}$/i).first
  #   else
  #     super
  #   end
  # end
  # def self.from_omniauth(auth)
  #   find_by(facebook_uid: auth["uid"]) || create_with_omniauth(auth)
  # end

  # def self.create_with_omniauth(auth)
  #   user = find_by(email: auth["info"]["email"])
  #   params = {facebook_uid: auth["uid"], first_name: auth["info"]["first_name"], last_name: auth["info"]["last_name"]}
  #   return user.update_attributes(params) if user.present?
  #   return User.create(params.merge!({email: auth["info"]["email"], password: Devise.friendly_token[0,20], gender: auth["extra"]["raw_info"]["gender"]}))
  # end


  ################# REDO THE FOLLOWING METHODS ACCORDING TO THE NEW STRUCTURE
  def self.calculate_general_achievements_stats(zone, start_range, end_range)
    achievements = Achievement.for_users(self.send(zone.to_s.pluralize.to_sym).to_a).for_range(start_range, end_range)
    user_scores = Hash.new
    achievements.each{ |a| user_scores[a.user] = (user_scores[a.user] || 0) + a.completed_tasks.sum(:points) }
    Hash[*user_scores.sort_by{|k,v| v}.reverse.flatten.take(10)]
  end

  def self.calculate_activities_achievements_stats(zone, start_range, end_range)
    achievements = Achievement.for_users(self.send(zone.to_s.pluralize.to_sym).to_a).for_range(start_range, end_range)
    involved_activities = Schedule.zone(zone).with_start_and_end(start_range, end_range).map{|s| s.tasks.map(&:activity)}.flatten.uniq
    User.get_top_in_activities(achievements, involved_activities)
  end

  def self.get_top_in_activities(achievements, activities)
    results = Hash.new
    achievements = achievements.group_by(&:user)
    activities.each do |act|
      results[act.title] = Hash.new
      achievements.keys.each{|a| results[act.title][a] = (results[act.title][a] || 0) + Achievement.calculate_activity_score(achievements[a], act)}
      results[act.title] = Hash[*results[act.title].sort_by{|k,v| v}.reverse.take(10).flatten]
    end
    results
  end
  ############## end of redo ###################

  # Follow up for each user 
  def self.follow_up_report(zone, start_range, end_range)
    achievements = Achievement.for_users(self.send(zone.to_s.pluralize.to_sym).to_a).for_range(start_range, end_range)
    # zone_schedules = Schedule.zone(:male).with_start_and_end(start_range, end_range)
    zone_schedules = Schedule.zone(zone)
    activities_w_scores = Hash.new
    zone_schedules.each do |s|
      activities_w_scores[s] = s.activitis_score_hash
    end
    follow_up_messages = FollowUpActivityMessage.for_levels(zone_schedules.map(&:level).flatten.uniq)
    User.think(achievements, activities_w_scores, follow_up_messages, start_range, end_range)
  end


  def self.think(achievements, activities_hash, messages, start_range, end_range)
    results = Hash.new
    users_ach = achievements.group_by(&:user)
    users_ach.keys.each do |user|
      results[user] = user.prepare_user_score_hash(users_ach[user], activities_hash)
      # date_ach: hash of keys[date] and values = achievements
      date_ach = users_ach[user].group_by(&:date)
      # get selected schedule for the week or the first few days
      selected_schedule = user.first_selected_schedule_from_achievements(start_range, date_ach, end_range)
      # Looping through week days and calculates each day score and updates the results[user] hash with the calculated values
      user.calculate_days_score_hash(start_range, end_range, date_ach, selected_schedule, results[user], activities_hash)
      user.follow_up_messages_with_score(messages, results[user], user.level(start_range).level)
    end
    results
  end

  def calculate_days_score_hash(start_range, end_range, date_ach, selected_schedule, user_hash, activities_hash)
    start_range.upto(end_range).each do |date|
      ## act_tasks_ach: hash of keys[activity_task] and values = completed_task
      if date_ach[date]
        schedule_date_ach = date_ach[date].group_by(&:schedule)
        schedule_date_ach.keys.each{|s| schedule_date_ach[s] = schedule_date_ach[s].map(&:completed_tasks).flatten.group_by{|t| t.activity_task.activity}}
      end
      user_hash.keys.each do |s|
        next if selected_schedule && selected_schedule != s
        user_hash[s].keys.each do |ac|
          total_score = activities_hash[s][ac]
          day_score = date_ach[date] && schedule_date_ach[s][ac] ? schedule_date_ach[s][ac].map(&:points).flatten.inject(0, :+) : 0
          user_hash[s][ac] << ((day_score/(total_score*1.0))*100).ceil
        end
      end
      selected_schedule = self.day_selected_schedule(selected_schedule, date_ach[date+1])
    end
  end

  def day_selected_schedule(prev_selected_schedule, day_achievements)
    case day_achievements.try(:count)
    when 1
      day_achievements.first.schedule
    when 2
      nil
    else
      prev_selected_schedule
    end
  end

  def follow_up_messages_with_score(messages, user_hash, user_level)
    user_hash.keys.each do |s|
      user_hash[s].keys.each do |a|
        unless user_hash[s][a].empty?
          tmp_hash = Hash.new
          tmp_hash[:score] = (user_hash[s][a].flatten.inject(0, :+) / (user_hash[s][a].count*1.0)).ceil
          tmp_hash[:message] = messages.level(user_level).activity(a).range(tmp_hash[:score]).try(:first).try(:message)
          user_hash[s][a] = tmp_hash
        end
      end
    end
  end

  def first_selected_schedule_from_achievements(start_range, date_ach, end_range)
    first_date = start_range
    while date_ach[first_date].nil? && first_date <= end_range
      first_date += 1
    end
    date_ach[first_date].first.schedule if date_ach[first_date].count == 1
  end

  def prepare_user_score_hash(users_ach, activities_hash)
    results = Hash.new
    users_ach.map(&:schedule).flatten.each do |s|
      results[s] = Hash.new 
      activities_hash[s].keys.each { |a| results[s][a] = []}
    end
    results
  end

  def calculate_activity_score(achievements, user_hash, activities)
    activities.each { |a| user_hash[a] = 0 }
    # get achievements by day and get percentage for this day according to completed tasks schedule
    temp_hash = Hash.new
    achievements.group_by(&:date).values.each do |a|
      schedules = a.completed_tasks.flatten.group_by(&:schedule)
      grouped_tasks = schedules.group_by(&:activity)
      grouped_tasks.keys.each do |ac|
        grouped_tasks[ac].map(&:points).flatten.inject(0, :+)
        temp_hash[ac] += []
      end
    end
    achievements.map(&:completed_tasks).flatten.each do |t|
      user_hash[t.activity] += t.points
    end
  end

  def role?(role)
    self.role == role
  end

  def schedules(date)
    Schedule.zone(self.gender.downcase).within(date)
  end

  def completed?(task, date)
    self.achievements.where(date: date).first.try(:completed_tasks).try(:include?, task)
  end

  def completed_task_ids
    self.achievements.map(&:completed_task_ids).flatten
  end

  def completed_tasks_by_day(achievements=nil)
    results = Hash.new
    achievements = achievements || self.achievements
    achievements.each { |a| results[a.date] = (results[a.date] || [] )+ a.completed_tasks}
    results
  end

  def total_points(achievements, start_range=nil, end_range=nil)
    score = unless start_range
              achievements
            else
              achievements.for_range(start_range, end_range)
            end.map{|a| a.completed_tasks.map(&:points)}.flatten.inject(0, :+)
  end

  def level(date)
    self.levels.for_date(date).try(:first)
  end

  protected

  # def generate_code
  #   gender_count = User.where(gender: self.gender).count + 1
  #   self.code_name = GENDER_PREFIX_CODE[self.gender.downcase] + gender_count.to_s
  # end

  def skip_confirmation_mail
    self.skip_confirmation!
  end

end
