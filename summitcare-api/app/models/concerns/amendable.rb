module Amendable
  extend ActiveSupport::Concern

  included do
    has_many :amendment_requests, as: :target
    has_many :record_amendments, as: :target
  end

  # Material that must accompany this record when it is disclosed (§164.526(c)–(d)).
  def amendment_materials
    record_amendments.includes(:amendment_request).order(:created_at).select do |m|
      m.kind == "amendment" || m.amendment_request.include_with_disclosures?
    end
  end
end
