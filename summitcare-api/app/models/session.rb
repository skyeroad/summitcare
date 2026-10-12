class Session < ApplicationRecord
  include SessionExpiry
  tracks_activity_in :last_active_at

  belongs_to :user
end
