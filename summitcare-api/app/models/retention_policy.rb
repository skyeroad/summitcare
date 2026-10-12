class RetentionPolicy
  attr_reader :key, :model, :period, :trigger_column, :legal_basis, :owner

  def self.all
    Rails.application.config_for(:retention).map { |key, attrs| new(key, attrs) }
  end

  def initialize(key, attrs)
    @key = key.to_s
    @model = attrs.fetch(:model).constantize
    @period = attrs.fetch(:years, 0).years + attrs.fetch(:days, 0).days
    @trigger_column, @legal_basis, @owner = attrs.values_at(:trigger_column, :legal_basis, :owner)
  end

  def expired_scope
    scope = model.where(trigger_column => ...period.ago)
    return scope unless model.column_names.include?("patient_id")
    scope.where.not(patient_id: LegalHold.active.select(:patient_id))
  end
end
