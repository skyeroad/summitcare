# Sends a generic, PHI-free text message through Amazon SNS (Solution 21).
# AWS is BAA-covered in config/vendors.yml; the text still carries no PHI.
class SmsDeliveryJob < ApplicationJob
  def perform(preference, text, client: Aws::SNS::Client.new(region: "us-east-1"))
    client.publish(phone_number: preference.destination, message: text,
                   message_attributes: { "AWS.SNS.SMS.SMSType" => { data_type: "String", string_value: "Transactional" } })
  end
end
