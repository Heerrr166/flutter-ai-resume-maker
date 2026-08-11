// Deterministic writing-transformation rules used by the local Resume
// Intelligence Engine. Every rule here rewrites *how* existing user text is
// phrased (tone, structure) - none of them add facts, numbers, employers, or
// achievements that were not already present in the input.

// Weak/passive openers, ordered longest-phrase-first so a longer match wins
// over a shorter substring of itself. Each maps to a strong action verb used
// to replace the opener while leaving the rest of the sentence untouched.
const WEAK_OPENER_REPLACEMENTS = [
  ['was responsible for', 'Managed'],
  ['responsible for', 'Managed'],
  ['worked closely with', 'Collaborated with'],
  ['worked on', 'Developed'],
  ['worked as', 'Served as'],
  ['helped with', 'Contributed to'],
  ['helped to', 'Contributed to'],
  ['assisted with', 'Supported'],
  ['assisted in', 'Supported'],
  ['involved in', 'Participated in'],
  ['in charge of', 'Led'],
  ['tasked with', 'Delivered'],
  ['duties included', 'Delivered'],
  ['my job was to', 'Delivered'],
];

// Filler words/phrases stripped from bullet text - they add no information
// and read as informal for a resume.
const FILLER_WORDS = [
  'very', 'really', 'basically', 'actually', 'just', 'simply', 'literally',
  'kind of', 'sort of', 'a lot of', 'various', 'stuff', 'things',
];

// A bullet is considered "quantified" if it contains a number, percentage,
// currency amount, or similar measurable token.
const QUANTIFICATION_PATTERN = /\d/;

// When a weak opener ("worked on", "helped with", ...) is immediately
// followed by a gerund ("...deploying the app"), simply prepending a strong
// verb reads awkwardly ("Developed deploying the app"). Converting that
// leading gerund to past tense instead ("Deployed the app") reads naturally.
// Covers common resume verbs; irregular/doubled-consonant forms are listed
// explicitly since the naive "-ing" -> "-ed" rule gets those wrong.
const GERUND_TO_PAST = {
  building: 'Built', running: 'Ran', writing: 'Wrote', leading: 'Led',
  planning: 'Planned', debugging: 'Debugged', shipping: 'Shipped',
  cutting: 'Cut', setting: 'Set', getting: 'Got', winning: 'Won',
};

// Generic English stopwords excluded from job-description keyword
// extraction so matching focuses on meaningful terms.
const STOPWORDS = new Set([
  'a', 'an', 'the', 'and', 'or', 'but', 'if', 'then', 'so', 'to', 'of', 'in',
  'on', 'for', 'with', 'as', 'by', 'at', 'from', 'is', 'are', 'was', 'were',
  'be', 'been', 'being', 'this', 'that', 'these', 'those', 'it', 'its',
  'we', 'you', 'your', 'our', 'they', 'their', 'will', 'would', 'should',
  'can', 'could', 'may', 'might', 'must', 'have', 'has', 'had', 'do', 'does',
  'did', 'not', 'no', 'yes', 'about', 'into', 'through', 'per', 'etc',
  'including', 'such', 'other', 'all', 'any', 'more', 'most', 'some',
  'who', 'what', 'when', 'where', 'which', 'while', 'within', 'across',
]);

module.exports = {
  WEAK_OPENER_REPLACEMENTS,
  FILLER_WORDS,
  QUANTIFICATION_PATTERN,
  GERUND_TO_PAST,
  STOPWORDS,
};
