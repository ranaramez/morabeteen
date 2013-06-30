class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Constants
  GENDERS = [:male, :female]

  GENDER_PREFIX_CODE = {
    male: "11",
    female: "10"
  }
  ROLES = [:admin, :default]

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
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
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  # Fields
  field :first_name
  field :last_name
  field :facebook_uid
  field :gender,             type: Symbol
  field :code_name,          type: String
  field :role,               type: Symbol

  #Extensions
  slug :code_name
  # mount_uploader :avatar, AvatarUploader
  
  # Relations
  has_many :achievements
  
  # Validations
  validates_presence_of :gender

  # Callbacks
  before_create :generate_code
  before_create :skip_confirmation_mail, if: ->{self.facebook_uid.present?}
  
  scope :females, where(gender: :female)
  scope :males, where(gender: :male)
  # Methods
  def name
    "#{first_name} #{last_name}"
  end

  def self.from_omniauth(auth)
    find_by(facebook_uid: auth["uid"]) || create_with_omniauth(auth)
  end

  def self.create_with_omniauth(auth)
    user = find_by(email: auth["info"]["email"])
    params = {facebook_uid: auth["uid"], first_name: auth["info"]["first_name"], last_name: auth["info"]["last_name"]}
    return user.update_attributes(params) if user.present?
    return User.create(params.merge!({email: auth["info"]["email"], password: Devise.friendly_token[0,20], gender: auth["extra"]["raw_info"]["gender"]}))
  end

  def self.calculate_general_achievements_stats(zone, start_range, end_range)
    achievements = Achievement.for_users(self.send(zone.to_s.pluralize.to_sym).to_a).for_range(start_range, end_range)
    user_scores = Hash.new
    achievements.each{ |a| user_scores[a.user] = (user_scores[a.user] || 0) + a.completed_tasks.sum(:points) }
    Hash[*user_scores.sort_by{|k,v| v}.reverse.flatten.take(10)]
  end

  def self.calculate_activities_achievements_stats(zone, start_range, end_range)
    Achievement.for_users(self.send(zone.to_s.pluralize.to_sym).to_a).for_range(start_range, end_range)
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
    achievements.each { |a| results[a.date] = a.completed_tasks}
    results
  end

  def total_points(achievements, start_range=nil, end_range=nil)
    score = unless start_range
              achievements
            else
              achievements.for_range(start_range, end_range)
            end.map{|a| a.completed_tasks.map(&:points)}.flatten.inject(0, :+)
  end

  protected

  def generate_code
    gender_count = User.where(gender: self.gender).count + 1
    self.code_name = GENDER_PREFIX_CODE[self.gender.downcase] + gender_count.to_s
  end

  def skip_confirmation_mail
    self.skip_confirmation!
  end

end
