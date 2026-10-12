# Blind index key for exact-match phone lookup (Solution 7). It is separate
# from the Active Record Encryption keys. Development and test use a fixed,
# throwaway key; production must set BLIND_INDEX_MASTER_KEY (64 hex characters).
BlindIndex.master_key =
  if Rails.env.local?
    ENV.fetch("BLIND_INDEX_MASTER_KEY", "5c1a9d5e0f6b4a3e8d2c7b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f10")
  else
    ENV.fetch("BLIND_INDEX_MASTER_KEY")
  end
