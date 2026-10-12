require "test_helper"

class PhiLogFilterTest < ActiveSupport::TestCase
  test "filter_parameters masks every registered PHI attribute" do
    Rails.application.eager_load!
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    leaks = ProtectedHealthInformation.registry.flat_map do |model_name, attributes|
      attributes.filter_map do |attribute|
        filtered = filter.filter(attribute.to_s => "Avery Quinn")
        "#{model_name}##{attribute}" unless filtered[attribute.to_s] == "[FILTERED]"
      end
    end
    assert_empty leaks, "PHI attributes that would appear in logs:\n#{leaks.join("\n")}"
  end
end
