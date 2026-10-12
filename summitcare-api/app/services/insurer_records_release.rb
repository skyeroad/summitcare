# Releases records to a life insurer only under an active, signed authorization
# (Solution 21). The transport is out of scope for the sample: staff send the
# package through the clinic's release-of-information process.
class InsurerRecordsRelease
  RECIPIENT = "Example Life Insurance Co."
  PURPOSE = "insurance_underwriting"

  def self.call(patient:, &deliver)
    authorization = DisclosureGate.authorize!(patient:, recipient: RECIPIENT,
                                              purpose: PURPOSE)
    # ... send the records within authorization.information_scope ...
    deliver&.call(patient, authorization.information_scope)
    Disclosure.record!(patient:, recipient_name: authorization.recipient, purpose: "authorization",
                       description: "Records released under authorization ##{authorization.id}")
  end
end
