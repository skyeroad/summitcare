require "test_helper"

class PushPayloadTest < ActiveSupport::TestCase
  test "push and email carry no message content or patient name" do
    message = messages(:avery_question)
    json = PushPayload.for_new_message(message, communication_preferences(:avery_push)).to_json
    mail = PatientMailer.notice(communication_preferences(:avery_email), PatientNotifier::TEMPLATES[:new_message])

    [json, mail.subject, mail.body.encoded].each do |text|
      refute_includes text, message.body
      refute_includes text, message.patient.first_name
    end
  end
end
