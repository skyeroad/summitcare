# The record that a person reviewed system activity for a period (Solution 17).
class ActivityReview < ApplicationRecord
  belongs_to :reviewed_by, class_name: "User", optional: true
  validates :period_start, :period_end, presence: true
end
