class Activity
  include Mongoid::Document

  field :title

  # Associations
  has_many :tasks

  # Callbacks
  before_destroy :check_if_can_destroy


  protected

  def check_if_can_destroy
    return false if self.tasks.present?
  end
end