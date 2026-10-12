class PatientMailer < ApplicationMailer
  def notice(preference, text)
    @text = text
    @sign_in_url = "https://summitcare.example/sign-in"
    mail to: preference.destination, subject: "You have an update in SummitCare"
  end
end
