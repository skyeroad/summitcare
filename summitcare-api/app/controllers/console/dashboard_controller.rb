class Console::DashboardController < Console::BaseController
  def show
    authorize :dashboard, :show?
    render json: {
      open_anomaly_findings: AnomalyFinding.where(status: "open").count,
      break_glass_awaiting_review: BreakGlassGrant.awaiting_review.count,
      outstanding_record_requests: RecordRequest.outstanding.count
    }
  end
end
