require "test_helper"

# Not in the book: Solution 15's before_send against the installed sentry-ruby.
class SentryScrubbingTest < ActiveSupport::TestCase
  test "before_send drops extras and scrubs PHI patterns from exception messages" do
    error = (raise "Patient SC-100231 avery@example.com born 1984-03-12" rescue $!)
    event = Sentry::ErrorEvent.new(configuration: Sentry.configuration)
    event.add_exception_interface(error, mechanism: Sentry::Mechanism.new(type: "generic", handled: true))
    event.extra = { mrn: "SC-100231" }

    scrubbed = Sentry.configuration.before_send.call(event, {})
    assert_empty scrubbed.extra
    message = scrubbed.exception.values.map(&:value).join
    refute_match(/SC-100231|avery@example\.com|1984-03-12/, message)
  end
end
