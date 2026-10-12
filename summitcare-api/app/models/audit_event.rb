class AuditEvent < ApplicationRecord
  ACTIONS = %w[view list create update delete export disclose download
               sign_in sign_in_failed sign_out break_glass ai_request].freeze
  GENESIS = "0" * 64
  CHAIN_LOCK = 7_331_001 # any constant bigint, used only for this chain
  CHAINED_FIELDS = %w[occurred_at actor_id actor_role action subject_type subject_id
                      patient_id ip_address user_agent request_id device_session_id reason].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :occurred_at, presence: true
  before_create :link_to_chain

  # Persisted events can never be saved or destroyed through Active Record.
  def readonly? = persisted? || super

  def compute_digest(previous)
    OpenSSL::Digest::SHA256.hexdigest("#{previous}\n#{canonical_json}")
  end

  def canonical_json
    fields = CHAINED_FIELDS.to_h { |name| [name, self[name]&.to_s] }
    fields["occurred_at"] = occurred_at.utc.iso8601(6)
    JSON.generate(fields.merge("metadata" => self.class.canonicalize(metadata)))
  end

  def self.canonicalize(value)
    case value
    when Hash then value.to_h { |k, v| [k.to_s, canonicalize(v)] }.sort.to_h
    when Array then value.map { |v| canonicalize(v) }
    else value
    end
  end

  private

  def link_to_chain
    self.class.with_connection { |c| c.execute("SELECT pg_advisory_xact_lock(#{CHAIN_LOCK})") }
    self.previous_digest = self.class.order(id: :desc).pick(:digest) || GENESIS
    self.digest = compute_digest(previous_digest)
  end
end
