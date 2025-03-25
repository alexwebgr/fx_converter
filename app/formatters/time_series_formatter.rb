# frozen_string_literal: true

class TimeSeriesFormatter
  attr_reader :payload

  def self.call(payload)
    new(payload).call
  end

  def initialize(payload)
    @payload = payload
  end

  def call
    return payload if payload[:message]

    payload.delete(:amount)
    payload
  end
end
