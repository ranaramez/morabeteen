class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.role? :admin
      can :manage, :all
    else
      can :update, Task
      can :read, User
      can :update_achievemnt, User, id: user.id
    end
  end
end
