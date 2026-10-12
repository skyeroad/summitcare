# Server-side, single-use WebAuthn challenges (Solution 1). Never in a cookie.
module PasskeyChallenges
  CHALLENGE_TTL = 5.minutes

  private

  def store_challenge(challenge)
    SecureRandom.uuid.tap do |id|
      Rails.cache.write("passkey-challenge/#{id}", challenge, expires_in: CHALLENGE_TTL)
    end
  end

  def take_challenge(id)
    return if id.blank?
    key = "passkey-challenge/#{id}"
    Rails.cache.read(key).tap { Rails.cache.delete(key) }
  end
end
