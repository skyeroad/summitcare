require "test_helper"

class ClinicalAssistantTest < ActiveSupport::TestCase
  FakeLlm = Struct.new(:prompts) do
    def complete(system:, prompt:, **)
      prompts << prompt
      BedrockLlmClient::Result.new(text: "Hi [FIRST_NAME], thanks for writing.", model_id: "test-model",
                                   input_tokens: 42, output_tokens: 9)
    end
  end

  test "redacts identifiers and audits without prompt text" do
    message = messages(:avery_question)   # body mentions "Avery" and "SC-100231"
    llm = FakeLlm.new([])
    draft = ClinicalAssistant.new(llm: llm).draft_reply(message)

    refute_match(/Avery|SC-100231/, llm.prompts.first)
    assert_equal "Hi Avery, thanks for writing.", draft
    event = AuditEvent.where(action: "ai_request").last
    refute_includes event.metadata.to_json, "SC-100231"
    assert_equal 42, event.metadata["input_tokens"]
  end

  # Not in the book: the real client against a stubbed Bedrock (no network).
  test "BedrockLlmClient reads text and token usage from Converse" do
    bedrock = Aws::BedrockRuntime::Client.new(region: "us-east-1", stub_responses: {
      converse: { output: { message: { role: "assistant", content: [{ text: "Draft" }] } },
                  usage: { input_tokens: 5, output_tokens: 1, total_tokens: 6 },
                  stop_reason: "end_turn", metrics: { latency_ms: 1 } }
    })
    result = BedrockLlmClient.new(client: bedrock).complete(system: "s", prompt: "p")
    assert_equal ["Draft", 5, 1], [result.text, result.input_tokens, result.output_tokens]
  end
end
