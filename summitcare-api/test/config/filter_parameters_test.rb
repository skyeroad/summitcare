require "test_helper"

class FilterParametersTest < ActiveSupport::TestCase
  test "every registered PHI attribute is filtered" do
    Rails.application.eager_load!
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    ProtectedHealthInformation.registry.each do |model, attributes|
      attributes.each do |attribute|
        filtered = filter.filter(attribute.to_s => "synthetic")
        assert_equal "[FILTERED]", filtered[attribute.to_s], "#{model}.#{attribute} is not filtered"
      end
    end
  end
end
