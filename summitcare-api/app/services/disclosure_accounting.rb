class DisclosureAccounting
  LOOKBACK = 6.years
  Row = Data.define(:date, :recipient, :address, :description, :purpose)

  def initialize(patient, requested_at: Time.current, since: nil)
    @patient = patient
    @range = [since, requested_at - LOOKBACK].compact.max..requested_at
  end

  def rows
    @patient.disclosures.for_accounting.where(disclosed_at: @range).order(:disclosed_at).map do |d|
      Row.new(date: d.disclosed_at.to_date, recipient: d.recipient_name,
              address: d.recipient_address, description: d.description,
              purpose: d.purpose.humanize)
    end
  end
end
