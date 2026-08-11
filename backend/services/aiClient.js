const Anthropic = require('@anthropic-ai/sdk');

const MODEL = process.env.ANTHROPIC_MODEL || 'claude-opus-5';

let client = null;

// Lazy singleton: the API key is only read when a request actually needs it,
// so a missing key fails the specific AI call rather than crashing boot.
const getClient = () => {
  if (client) return client;
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    throw { status: 503, message: 'AI features are not configured on this server' };
  }
  client = new Anthropic({ apiKey, timeout: 30_000 });
  return client;
};

// Thin wrapper around a single non-streaming Messages API call. Thinking is
// disabled: these are short, deterministic rewriting/generation tasks with no
// tool use, so thinking only adds latency and cost with no quality benefit
// here (and stays within the "disabled thinking" ceiling since effort is left
// at its high default).
const complete = async ({ system, prompt, maxTokens = 1024, jsonSchema }) => {
  const anthropic = getClient();

  let response;
  try {
    response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: maxTokens,
      thinking: { type: 'disabled' },
      system,
      messages: [{ role: 'user', content: prompt }],
      ...(jsonSchema ? { output_config: { format: { type: 'json_schema', schema: jsonSchema } } } : {}),
    });
  } catch (error) {
    if (error instanceof Anthropic.RateLimitError) {
      throw { status: 429, message: 'AI provider is rate-limited, please try again shortly' };
    }
    if (error instanceof Anthropic.AuthenticationError || error instanceof Anthropic.PermissionDeniedError) {
      throw { status: 503, message: 'AI features are not configured correctly on this server' };
    }
    throw { status: 502, message: 'AI request failed, please try again' };
  }

  if (response.stop_reason === 'refusal') {
    throw { status: 422, message: 'The AI declined to process this request' };
  }

  const textBlock = response.content.find((block) => block.type === 'text');
  const text = textBlock ? textBlock.text.trim() : '';

  if (jsonSchema) {
    try {
      return JSON.parse(text);
    } catch (error) {
      throw { status: 502, message: 'AI response could not be parsed, please try again' };
    }
  }

  return text;
};

module.exports = { complete };
