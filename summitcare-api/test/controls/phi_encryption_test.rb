require "test_helper"

class PhiEncryptionTest < ActiveSupport::TestCase
  setup { Rails.application.eager_load! }

  test "every PHI-looking column is encrypted" do
    config = Rails.application.config_for(:compliance)
    patterns = config[:phi_column_patterns].map { |source| Regexp.new(source) }
    exempt = config[:phi_column_exemptions].keys.map(&:to_s)

    unencrypted = ApplicationRecord.descendants.reject(&:abstract_class?).flat_map do |model|
      next [] unless model.table_exists?

      encrypted = Array(model.encrypted_attributes).map(&:to_s)
      model.column_names.filter_map do |column|
        key = "#{model.name}##{column}"
        next if exempt.include?(key) || encrypted.include?(column)

        key if patterns.any? { |pattern| column.match?(pattern) }
      end
    end
    assert_empty unencrypted, "Columns that look like PHI but are not encrypted:\n#{unencrypted.join("\n")}"
  end

  test "every registered PHI attribute is encrypted" do
    ProtectedHealthInformation.registry.each do |model_name, attributes|
      model = model_name.constantize
      missing = attributes.map(&:to_s) - Array(model.encrypted_attributes).map(&:to_s)
      assert_empty missing, "#{model.name} registers PHI it does not encrypt: #{missing.join(', ')}"
    end
  end
end
