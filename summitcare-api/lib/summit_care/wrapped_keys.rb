require "aws-sdk-kms"
require "base64"

# Unwraps the production Active Record Encryption keys with AWS KMS at boot
# (Solution 8). Each environment variable holds one or more comma-separated,
# Base64-encoded KMS ciphertext blobs produced by `aws kms encrypt`.
module SummitCare
  module WrappedKeys
    CONTEXT = { "app" => "summitcare-api", "purpose" => "active-record-encryption" }.freeze

    def self.unwrap_list(env_name)
      ENV.fetch(env_name).split(",").map { |blob| unwrap(blob) }
    end

    def self.unwrap(blob)
      client.decrypt(key_id: "alias/summitcare-db",
                     ciphertext_blob: Base64.strict_decode64(blob),
                     encryption_context: CONTEXT).plaintext
    end

    def self.client = (@client ||= Aws::KMS::Client.new)
  end
end
