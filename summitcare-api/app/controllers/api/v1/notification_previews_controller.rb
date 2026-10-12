class Api::V1::NotificationPreviewsController < Api::V1::BaseController
  def show
    message = authorize Message.find(params[:id]), :show?
    push = message.patient.communication_preferences.find_by(channel: "push")
    return head(:no_content) unless push&.allow_message_preview?

    AuditLog.record!(action: "view", subject: message, patient: message.patient,
                     reason: "notification_preview")
    render json: { title: "Message from your care team", body: message.body.truncate(80) }
  end
end
