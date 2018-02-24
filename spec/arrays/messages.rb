require 'base_element'
require 'recipient_type'

class Messages
  include BaseElement

  def recipient
    array_of_at(RecipientType, [:recipient])
  end

  def error
    array_of_at(String, [:error])
  end

  def to_h
    { recipient: recipient.map(&:to_h),
      error: error
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
