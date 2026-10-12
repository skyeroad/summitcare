# One row per partner webhook delivery; the unique index stops replays (Solution 27).
class WebhookReceipt < ApplicationRecord
  belongs_to :partner
end
