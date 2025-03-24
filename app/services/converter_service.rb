# frozen_string_literal: true

require 'net/http'
require_relative "credentials_manager"

class ConverterService
  BASE_URL = "https://api.currencyapi.com/v3/"

  # format USD
  attr_reader :base_currency
  # format "USD,EUR"
  attr_reader :currencies
  # format 2025-03-23
  attr_reader :date
  # available
  # * latest
  # * historical
  # for historical the date is a required param
  attr_reader :endpoint

  def self.call(base_currency, currencies, endpoint, date)
    new(base_currency, currencies, endpoint, date).call
  end

  def initialize(base_currency, currencies, endpoint, date = nil)
    @base_currency = base_currency
    @currencies = currencies
    @date = date
    @endpoint = endpoint
  end

  def call
    endpoints = {
      "latest" => "latest",
      "historical" => "historical"
    }

    return if endpoint.nil? ||
              base_currency.nil? ||
              currencies.empty? ||
              endpoints[endpoint].nil?

    send endpoints[endpoint]
  end

  private

  def latest
    url_params = {
      apikey: access_key,
      base_currency: base_currency,
      currencies: currencies
    }

    call_service(endpoint, url_params)

    # {meta: {last_updated_at: "2025-03-23T23:59:59Z"}, data: {JPY: {code: "JPY", value: 162.2623073797}, USD: {code: "USD", value: 1.0841751739}}}
  end

  def historical
    url_params = {
      apikey: access_key,
      base_currency: base_currency,
      currencies: currencies,
      date: date
    }

    call_service(endpoint, url_params)
  end

  def access_key
    @access_key ||= CredentialsManager.new.read["currency_api_key"]
  end

  def call_service(endpoint, url_params)
    uri = URI([BASE_URL, endpoint].join("/"))
    uri.query = URI.encode_www_form(url_params)
    res = Net::HTTP.get_response(uri)

    JSON.parse(res.body, symbolize_names: true)
  end
end
