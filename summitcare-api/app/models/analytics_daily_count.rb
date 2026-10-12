class AnalyticsDailyCount < ApplicationRecord
  def self.add(event:, total:)
    upsert({ day: Date.current, event: event, total: total },
           unique_by: %i[day event],
           on_duplicate: Arel.sql("total = analytics_daily_counts.total + EXCLUDED.total"))
  end
end
