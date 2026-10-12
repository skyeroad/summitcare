# Tells compliance officers that emergency access was opened (Solution 6).
# IDs and a console link only; the reason and patient stay in the console.
class BreakGlassMailer < ApplicationMailer
  def opened
    @grant = params[:grant]
    @url = "https://summitcare.example/console/break_glass_grants/#{@grant.id}"
    mail to: User.compliance_officer.where(deactivated_at: nil).pluck(:email_address),
         subject: "SummitCare: emergency access opened (grant #{@grant.id})"
  end
end
