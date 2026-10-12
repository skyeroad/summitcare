class VendorRegistry
  Vendor = Data.define(:key, :name, :purpose, :receives_phi, :baa_signed_on, :baa_document,
                       :covered_services, :data_categories, :hosts, :sdks, :review_by) do
    def phi_allowed? = receives_phi == true && baa_signed_on.present?
    def covers_host?(host) = Array(hosts).any? { |pattern| File.fnmatch?(pattern, host.to_s) }
    def review_overdue? = review_by.nil? || review_by < Date.current
  end

  class UnknownVendor < KeyError; end

  def self.fetch(key)
    all.fetch(key.to_sym) { raise UnknownVendor, "#{key} is not in config/vendors.yml" }
  end

  def self.all
    @all ||= YAML.load_file(Rails.root.join("config/vendors.yml"), permitted_classes: [Date])
      .fetch("vendors").to_h do |key, raw|
        attrs = Vendor.members.index_with { nil }
          .merge(raw.symbolize_keys.slice(*Vendor.members))
          .merge(key: key.to_sym)
        [key.to_sym, Vendor.new(**attrs)]
      end
  end
end
