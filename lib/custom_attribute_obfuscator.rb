# frozen_string_literal: true

class CustomAttributeObfuscator < Decidim::AttributeObfuscator

  def self.document_number(value, success = true)
    if success
      obfuscate(1, 2, value)
    else
      obfuscate(2, 2, value)
    end
  end

  def self.postal_code(value, success = true)
    if success
      obfuscate(2, 0, value)
    else
      obfuscate(1, 1, value)
    end
  end

  def self.email(full_email, success = true)
    return nil unless full_email.present? && full_email.include?("@")

    segments = full_email.split("@")
    local_part = segments.first

    obfuscated_local_part = if success
                              obfuscate(1, 0, local_part)
                            elsif local_part.length <= 6
                              obfuscate(1, 2, local_part)
                            else
                              obfuscate(3, 3, local_part)
                            end

    "#{obfuscated_local_part}@#{segments.second}"
  end

end
