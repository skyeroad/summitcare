class BreakGlassGrantPolicy < ApplicationPolicy
  def create? = user.clinician? && user.active?
  def review? = user.compliance_officer?
  def index? = user.compliance_officer?
end
