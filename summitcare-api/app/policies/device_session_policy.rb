class DeviceSessionPolicy < ApplicationPolicy
  def destroy? = record.user_id == user.id

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.where(user_id: user.id) # only your own devices
  end
end
