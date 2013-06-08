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

  #Extensions
  slug :code_name
  # mount_uploader :avatar, AvatarUploader
  
  # Relations
  
  # Validations
  validates_presence_of :gender

  # Callbacks
  before_create :generate_code
  before_create :skip_confirmation_mail, if: ->{self.facebook_uid.present?}
  

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

  protected

  def generate_code
    gender_count = User.where(gender: self.gender).count + 1
    self.code_name = GENDER_PREFIX_CODE[self.gender] + gender_count.to_s
  end

  def skip_confirmation_mail
    self.skip_confirmation!
  end

end
