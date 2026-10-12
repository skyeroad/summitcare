# Tells the patient a decision is ready (Solution 20). The written denial, with
# the basis and the patient's rights, is shown in the app after sign-in.
class AmendmentMailer < ApplicationMailer
  def denial(amendment_request)
    @sign_in_url = "https://summitcare.example/sign-in"
    email = amendment_request.patient.contact_points.find { |point| point.channel == "email" }
    mail to: email&.destination, subject: "A decision on your SummitCare correction request"
  end
end
