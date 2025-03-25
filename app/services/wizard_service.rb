# frozen_string_literal: true

require 'tty-prompt'
require_relative "../currencies"

class WizardService
  attr_reader :prompt

  def self.call
    new.call
  end

  def initialize
    @prompt = TTY::Prompt.new
  end

  def call
    print "Welcome to the FX converter!"

    collect_input
  end

  private

  def collect_input
    bc = base_currency
    tc = target_currencies(bc)
    endpoint = select_type
    date = select_date(endpoint)

    {
      base_currency: bc,
      target_currencies: tc,
      endpoint: endpoint,
      date: date
    }
  end

  def base_currency
    prompt.select("Select base currency:", currencies.values, filter: true, show_help: :always)
  end

  def target_currencies(bc)
    filtered_currencies = currencies
    filtered_currencies.delete(bc.to_sym)

    prompt.multi_select("Select target currencies:", filtered_currencies.values, filter: true, show_help: :always).join(",")
  end

  def select_type
    endpoints = [
      {
        value: "latest",
        name: "Latest"
      }, {
        value: "historical",
        name: "Historical"
      }, {
        value: "time_series_range",
        name: "Time Series over a period. e.g. 2025-03-10..2025-03-20"
      }, {
        value: "time_series_to_present",
        name: "Time Series up to present. e.g. 2025-03-20.."
      }
    ]

    prompt.select("Select type:", endpoints)
  end

  def select_date(endpoint)
    if endpoint == "historical"
      return prompt.ask("Enter date in YYYY-MM-DD format") do |q|
        q.validate(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Wrong format. Enter date in YYYY-MM-DD format.")
      end
    end

    if endpoint == "time_series_range"
      return prompt.ask("Enter date in YYYY-MM-DD..YYYY-MM-DD format. ") do |q|
        # q.validate(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Wrong format. Enter date in YYYY-MM-DD format.")
      end
    end

    if endpoint == "time_series_to_present"
      return prompt.ask("Enter date in YYYY-MM-DD.. format. ") do |q|
        # q.validate(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Wrong format. Enter date in YYYY-MM-DD format.")
      end
    end
  end

  def currencies
    Currencies::PAYLOAD.each_with_object({}) do |(k, v), memo|
      memo[k] = {
        value: k,
        name: "#{k} - #{v}"
      }
    end
  end
end
