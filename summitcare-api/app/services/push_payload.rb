class PushPayload
  GENERIC_BODY = "You have a new message in SummitCare."

  def self.for_new_message(message, preference)
    aps = { "alert" => { "title" => "SummitCare", "body" => GENERIC_BODY },
            "sound" => "default", "thread-id" => "messages" }
    aps["mutable-content"] = 1 if preference.allow_message_preview?
    { "aps" => aps, "message_id" => message.id.to_s }
  end

  # Any other notice: the fixed template text and nothing else.
  def self.generic(text)
    { "aps" => { "alert" => { "title" => "SummitCare", "body" => text }, "sound" => "default" } }
  end
end
