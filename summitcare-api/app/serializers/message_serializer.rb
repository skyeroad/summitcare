class MessageSerializer
  def initialize(message) = @message = message

  def as_json(*)
    { id: @message.id, patient_id: @message.patient_id, sender_id: @message.sender_id,
      body: @message.body, created_at: @message.created_at, read_at: @message.read_at }
  end
end
