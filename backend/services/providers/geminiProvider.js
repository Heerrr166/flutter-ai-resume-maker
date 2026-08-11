// Thin wrapper around the Gemini REST API (generativelanguage.googleapis.com).
// Uses native fetch (Node 18+) instead of an SDK dependency, so the provider
// layer has no extra package to track/version and stays easy to swap out.
//
// Mirrors the same complete({ system, prompt, maxTokens, jsonSchema }) shape
// the old Anthropic-backed aiClient.js used, so aiService.js can treat any
// provider interchangeably.

const API_BASE = 'https://generativelanguage.googleapis.com/v1beta/models';
const MODEL = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
const REQUEST_TIMEOUT_MS = 20_000;

const isConfigured = () => Boolean(process.env.GEMINI_API_KEY);

// Gemini's REST JSON Schema support is a subset of the full spec (no
// $ref/additionalProperties/etc). Callers only ever pass flat
// object/string/array/number schemas, so this only strips the few keywords
// Gemini rejects rather than implementing a general schema translator.
const sanitizeSchema = (schema) => {
  if (Array.isArray(schema)) return schema.map(sanitizeSchema);
  if (schema && typeof schema === 'object') {
    const out = {};
    for (const [key, value] of Object.entries(schema)) {
      if (key === 'additionalProperties' || key === '$schema') continue;
      out[key] = sanitizeSchema(value);
    }
    return out;
  }
  return schema;
};

const complete = async ({ system, prompt, maxTokens = 1024, jsonSchema }) => {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw { status: 503, message: 'AI features are not configured on this server', provider: 'gemini' };
  }

  const body = {
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    ...(system ? { systemInstruction: { parts: [{ text: system }] } } : {}),
    generationConfig: {
      maxOutputTokens: maxTokens,
      temperature: 0.6,
      ...(jsonSchema
        ? { responseMimeType: 'application/json', responseSchema: sanitizeSchema(jsonSchema) }
        : {}),
    },
  };

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  let response;
  try {
    response = await fetch(`${API_BASE}/${MODEL}:generateContent?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
  } catch (error) {
    if (error.name === 'AbortError') {
      throw { status: 504, message: 'AI request timed out, please try again', provider: 'gemini' };
    }
    throw { status: 502, message: 'AI request failed, please try again', provider: 'gemini' };
  } finally {
    clearTimeout(timer);
  }

  if (response.status === 429) {
    throw { status: 429, message: 'AI provider is rate-limited, please try again shortly', provider: 'gemini' };
  }
  if (response.status === 401 || response.status === 403) {
    throw { status: 503, message: 'AI features are not configured correctly on this server', provider: 'gemini' };
  }
  if (!response.ok) {
    throw { status: 502, message: 'AI request failed, please try again', provider: 'gemini' };
  }

  let payload;
  try {
    payload = await response.json();
  } catch (error) {
    throw { status: 502, message: 'AI response could not be parsed, please try again', provider: 'gemini' };
  }

  const candidate = payload.candidates && payload.candidates[0];
  const finishReason = candidate && candidate.finishReason;
  if (finishReason === 'SAFETY' || finishReason === 'PROHIBITED_CONTENT') {
    throw { status: 422, message: 'The AI declined to process this request', provider: 'gemini' };
  }

  const textPart = candidate && candidate.content && candidate.content.parts
    ? candidate.content.parts.find((p) => typeof p.text === 'string')
    : null;
  const text = textPart ? textPart.text.trim() : '';

  if (!text) {
    throw { status: 502, message: 'AI returned an empty response, please try again', provider: 'gemini' };
  }

  if (jsonSchema) {
    try {
      return JSON.parse(text);
    } catch (error) {
      throw { status: 502, message: 'AI response could not be parsed, please try again', provider: 'gemini' };
    }
  }

  return text;
};

module.exports = { complete, isConfigured, MODEL };
