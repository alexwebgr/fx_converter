# frozen_string_literal: true

require 'tty-prompt'
require_relative "../currencies"

class WizardService
  def self.call
    new.call
  end

  def call
    collect_input
  end

  private

  def collect_input
    prompt = TTY::Prompt.new

    print "Welcome to the FX converter!\n\n"

    base_currency = prompt.select("Select base currency:", currencies.values, filter: true, show_help: :always)

    currencies.delete(base_currency.to_sym)
    target_currencies = prompt
                        .multi_select("Select target currencies:", currencies.values, filter: true, show_help: :always)
    endpoint = prompt.select("Select type:", %w[latest historical])

    if endpoint == "historical"
      date = prompt.ask("Enter date in YYYY-MM-DD format") do |q|
        q.validate(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Wrong format. Enter date in YYYY-MM-DD format.")
      end
    end

    {
      base_currency: base_currency,
      target_currencies: target_currencies.join(","),
      endpoint: endpoint,
      date: date
    }
  end

  def currencies
    Currencies::PAYLOAD[:data].transform_values do |currency|
      {
        value: currency[:code],
        name: "#{currency[:code]} - #{currency[:name]}"
      }
    end
  end
end
