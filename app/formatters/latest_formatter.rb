# frozen_string_literal: true

class LatestFormatter
  attr_reader :payload

  def self.call(payload)
    new(payload).call
  end

  def initialize(payload)
    @payload = payload
  end

  def call
    return payload if payload[:message]

    hash = {}
    hash[payload[:date].to_sym] = {
      base: payload[:base],
      rates: payload[:rates]
    }

    hash
  end
end
