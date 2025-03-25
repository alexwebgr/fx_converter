# frozen_string_literal: true
#
# https://frankfurter.dev/
# https://api.frankfurter.dev/v1/currencies
# https://api.frankfurter.dev/v1/latest?base=EUR&symbols=CHF,GBP
# https://api.frankfurter.dev/v1/2000-01-01?base=EUR&symbols=CHF,GBP
# https://api.frankfurter.dev/v1/2024-01-01..
# https://api.frankfurter.dev/v1/2024-01-01..?symbols=USD
# https://api.frankfurter.dev/v1/2000-01-01..2000-12-31

require 'net/http'
require "json"
require_relative "../formatters/latest_formatter"
require_relative "../formatters/historical_formatter"
require_relative "../formatters/time_series_formatter"

class FrankfurterService
  BASE_URL = "https://api.frankfurter.dev/v1"

  # format USD
  attr_reader :base_currency
  # format "USD,EUR"
  attr_reader :currencies
  # format 2025-03-23
  attr_reader :date
  # @endpoints
  attr_reader :endpoint

  def self.call(base_currency, currencies, endpoint, date = nil)
    new(base_currency, currencies, endpoint, date).call
  end

  def initialize(base_currency, currencies, endpoint, date = nil)
    @base_currency = base_currency
    @currencies = currencies
    @date = date
    @endpoint = endpoint
  end

  def endpoints
    {
      "latest" => "latest",
      "historical" => "historical",
      "time_series_to_present" => "time_series",
      "time_series_range" => "time_series",
    }
  end

  def call
    return if endpoint.nil? ||
              base_currency.nil? ||
              currencies.empty?

    return if endpoints[endpoint].nil?

    if date_required?
      return { message: "required param date is missing" } if date.nil?
    end

    send endpoints[endpoint]
  end

  private

  def latest
    url_params = {
      base: base_currency,
      symbols: currencies
    }

    LatestFormatter.call call_service(endpoint, url_params)
  end

  def historical
    url_params = {
      base: base_currency,
      symbols: currencies
    }

    HistoricalFormatter.call call_service(date, url_params)
  end

  def time_series
    url_params = {
      base: base_currency,
      symbols: currencies
    }

    TimeSeriesFormatter.call call_service(date, url_params)
  end

  def call_service(endpoint, url_params)
    uri = URI([BASE_URL, endpoint].join("/"))
    uri.query = URI.encode_www_form(url_params)
    res = Net::HTTP.get_response(uri)

    JSON.parse(res.body, symbolize_names: true)
  end

  def date_required?
    ["historical", "time_series_to_present", "time_series_range"].include? endpoints[endpoint]
  end
end
