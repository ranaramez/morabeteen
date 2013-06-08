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
  field :code_name

  #Extensions
  slug :code_name
  # mount_uploader :avatar, AvatarUploader
  
  # Relations

  
  # Validations
  validates_presence_of :gender

  # Callbacks
  

  # Methods
  def name
    "#{first_name} #{last_name}"
  end

  def self.from_omniauth(auth)
    find_by(facebook_uid: auth["uid"]) || create_with_omniauth(auth)
  end

  def self.create_with_omniauth(auth)
    user = find_by(email: auth["info"]["email"]) || new
    user.facebook_uid = auth["uid"]
    user.first_name ||= auth["info"]["first_name"]
    user.last_name ||= auth["info"]["last_name"]
    user.email = auth["info"]["email"] unless user.email.present?
    user.gender ||= auth["extra"]["raw_info"]["gender"]
    user.password ||= Devise.friendly_token[0,20]
    user.skip_confirmation!
    user.save
    user
  end

end
