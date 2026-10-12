require "test_helper"

class PatientNotifierTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "confidential preference suppresses default destinations" do
    avery = patients(:avery)
    avery.communication_preferences.create!(channel: "sms", destination: "+1-555-0100")
    avery.communication_preferences.create!(channel: "email", destination: "avery.work@example.com",
                                            confidential: true)

    assert_no_enqueued_jobs(only: SmsDeliveryJob) do
      PatientNotifier.deliver(avery, :new_message)
    end
  end
end
