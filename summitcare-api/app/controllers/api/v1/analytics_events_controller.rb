class Api::V1::AnalyticsEventsController < Api::V1::BaseController
  EVENTS = %w[app_launched sign_in_succeeded messages_opened message_sent
              lab_results_opened record_export_requested].freeze
  allow_unauthenticated_access                                  # counts carry no user
  skip_after_action :verify_authorized, :verify_policy_scoped   # no PHI, no records
  rate_limit to: 30, within: 1.minute

  def create
    params.require(:counts).permit(*EVENTS).to_h.each do |event, total|
      AnalyticsDailyCount.add(event: event, total: total.to_i.clamp(0, 500))
    end
    head :accepted
  end
end
