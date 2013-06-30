class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.role? :admin
      can :manage, :all
    else
      can :update, Task
      can :read, User, id: user.id
      can :update_achievement, User, user_id: user.id
    end
  end
end
