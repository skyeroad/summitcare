module ProtectedHealthInformation
  extend ActiveSupport::Concern

  # { "Patient" => [:first_name, :last_name, ...], ... }
  def self.registry
    @registry ||= {}
  end

  def self.register(model, names)
    registry[model.name] = (registry.fetch(model.name, []) | names)
  end

  class_methods do
    def phi_attributes(*names, **options)
      encrypts(*names, **options)
      ProtectedHealthInformation.register(self, names)
    end
  end
end
