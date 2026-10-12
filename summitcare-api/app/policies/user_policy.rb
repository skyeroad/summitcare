class UserPolicy < ApplicationPolicy
  def manage_own_mfa? = record == user
end
