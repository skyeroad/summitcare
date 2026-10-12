# Written notice of a 30-day extension (45 CFR 164.524(b)(2)(ii), Solution 18).
# Goes to the patient's own contact address; it names no health information.
class RecordRequestMailer < ApplicationMailer
  def extension_notice(record_request, reason:)
    @reason = reason
    @new_due_on = record_request.effective_due_on
    @sign_in_url = "https://summitcare.example/sign-in"
    email = record_request.patient.contact_points.find { |point| point.channel == "email" }
    mail to: email&.destination, subject: "An update on your SummitCare records request"
  end
end
