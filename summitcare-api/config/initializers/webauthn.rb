# Passkeys (Solutions 1 and 2). The relying party ID is the web domain that
# serves apple-app-site-association.
WebAuthn.configure do |config|
  config.rp_id = "summitcare.example"
  config.rp_name = "SummitCare"
  config.allowed_origins = ["https://summitcare.example"]
end
