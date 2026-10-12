# Headless policy for the staff console's landing page.
class DashboardPolicy < ApplicationPolicy
  def show? = user.present? && !user.patient?
end
