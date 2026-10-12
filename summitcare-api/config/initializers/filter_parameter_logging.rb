# Be sure to restart your server when you modify this file.

# Parameters are partially matched (e.g. passw matches password) and filtered from
# the log file (Solution 15). The PHI attributes are copied from
# ProtectedHealthInformation.registry; test/config/filter_parameters_test.rb and
# test/controls/phi_log_filter_test.rb fail when a new PHI attribute is missing.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc,
  # PHI attributes from ProtectedHealthInformation.registry (kept in sync by a test)
  :first_name, :last_name, :date_of_birth, :phone, :address_line1, :city, :postal_code,
  :state, :mrn, :body, :notes, :value, :reason, :title, :destination, :description,
  :requested_change, :information_scope, /\Aq\z/
]
