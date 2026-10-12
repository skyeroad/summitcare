class ReencryptPhiJob < ApplicationJob
  queue_as :maintenance

  def perform(model_name)
    model_name.constantize.find_each(&:encrypt)
  end
end

# Enqueue one job per PHI model:
# Rails.application.eager_load!
# ProtectedHealthInformation.registry.each_key { |name| ReencryptPhiJob.perform_later(name) }
