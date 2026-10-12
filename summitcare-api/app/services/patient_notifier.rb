class PatientNotifier
  TEMPLATES = {
    new_message: "You have a new message from your SummitCare care team.",
    records_ready: "The records you requested are ready in the SummitCare app."
  }.freeze

  # message: is optional; Solution 24 uses it to put an opaque ID in push payloads.
  def self.deliver(patient, event, message: nil)
    text = TEMPLATES.fetch(event)
    patient.contact_points.each do |point|
      case point.channel
      when "email" then PatientMailer.notice(point, text).deliver_later
      when "sms"   then SmsDeliveryJob.perform_later(point, text)
      when "push"  then PushDeliveryJob.perform_later(point, text, message)
      when "mail"  then nil # postal mail is staff-driven
      end
    end
  end
end
