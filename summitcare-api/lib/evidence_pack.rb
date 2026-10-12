# Machine-readable evidence for the compliance evidence pack (Solution 35).
module EvidencePack
  def self.encryption_inventory
    Rails.application.eager_load!
    ProtectedHealthInformation.registry.map do |model_name, attributes|
      model = model_name.constantize
      encrypted = Array(model.encrypted_attributes).map(&:to_s)
      {
        model: model.name,
        table: model.table_name,
        attributes: attributes.map do |attribute|
          type = model.type_for_attribute(attribute.to_s)
          { name: attribute.to_s, encrypted: encrypted.include?(attribute.to_s),
            deterministic: type.respond_to?(:deterministic?) && type.deterministic? }
        end
      }
    end
  end

  def self.operational_status
    %w[backup_restore_drill audit_chain_verification].index_with do |control|
      ControlRun.where(control:, succeeded: true).maximum(:ran_at)&.utc&.iso8601
    end
  end
end
