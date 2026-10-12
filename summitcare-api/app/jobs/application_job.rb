class ApplicationJob < ActiveJob::Base
  self.log_arguments = false                   # job arguments stay out of logs (Solution 15)

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
