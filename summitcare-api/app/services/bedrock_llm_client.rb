class BedrockLlmClient
  Result = Data.define(:text, :model_id, :input_tokens, :output_tokens)

  def initialize(model_id: Rails.configuration.x.ai.model_id,
                 client: Aws::BedrockRuntime::Client.new(region: "us-east-1"))
    @model_id = model_id
    @client = client
  end

  def complete(system:, prompt:, max_tokens: 600)
    response = @client.converse(
      model_id: @model_id,
      system: [{ text: system }],
      messages: [{ role: "user", content: [{ text: prompt }] }],
      inference_config: { max_tokens: max_tokens, temperature: 0.2 }
    )
    Result.new(text: response.output.message.content.first.text, model_id: @model_id,
               input_tokens: response.usage.input_tokens, output_tokens: response.usage.output_tokens)
  end
end
