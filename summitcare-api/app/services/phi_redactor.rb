class PhiRedactor
  PATTERNS = {
    "[MRN]" => /\bSC-\d{6}\b/,
    "[EMAIL]" => /\b[\w.+-]+@[\w-]+(?:\.[\w-]+)+\b/,
    "[PHONE]" => /\(?\b\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b/,
    "[DATE]" => %r{\b\d{1,2}/\d{1,2}/\d{2,4}\b|\b\d{4}-\d{2}-\d{2}\b}
  }.freeze

  attr_reader :count

  def initialize(patient)
    @known = { "[FIRST_NAME]" => patient.first_name, "[LAST_NAME]" => patient.last_name }
    @count = 0
  end

  def redact(text)
    result = text.to_s.dup
    @known.each { |label, value| @count += result.gsub!(/\b#{Regexp.escape(value)}\b/i, label) ? 1 : 0 if value.present? }
    PATTERNS.each { |label, pattern| @count += result.gsub!(pattern, label) ? 1 : 0 }
    result
  end

  def restore_first_name(text) = text.gsub("[FIRST_NAME]", @known["[FIRST_NAME]"].to_s)
end
