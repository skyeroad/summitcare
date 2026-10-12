# Here `user` is the PartnerCredential that authenticated the request (Solution 27).
class PartnerPolicy < ApplicationPolicy
  def deliver_lab_results? =
    user.is_a?(PartnerCredential) && user.partner_id == record.id && user.allows?("lab_results:write")
end
