# frozen_string_literal: true
require_relative "../spec_helper"
require_relative "../../app/services/frankfurter_service"

describe FrankfurterService do
  context "when the endpoint is latest" do
    it "returns the rates" do
      base_currency, target_currencies, endpoint = ["EUR", "USD,GBP", "latest"]

      stub_request(:get, [described_class::BASE_URL, endpoint].join("/"))
        .with(query: {
          base: base_currency,
          symbols: target_currencies
        })
        .to_return(body: file_fixture("latest__api_response.json"))

      response = described_class.call(base_currency, target_currencies, endpoint)
      expect(response).to eq({
          "2025-03-24": {
            "base": "EUR",
            "rates": {
              "USD": 1.0824,
              "GBP": 0.83663
            }
          }
        })
    end

    context "and the currencies do not exist" do
      it "returns an error" do
        base_currency, target_currencies, endpoint = ["AED", "AFN", "latest"]

        stub_request(:get, [described_class::BASE_URL, endpoint].join("/"))
          .with(query: {
            base: base_currency,
            symbols: target_currencies
          })
          .to_return(body: { message: "not found" }.to_json)

        response = described_class.call(base_currency, target_currencies, endpoint)
        expect(response).to eq({ message: "not found" })
      end
    end
  end

  context "when the endpoint is historical" do
    it "returns the rates" do
      base_currency, target_currencies, endpoint, date = ["EUR", "USD,GBP", "historical", "2025-03-20"]

      stub_request(:get, [described_class::BASE_URL, date].join("/"))
        .with(query: {
          base: base_currency,
          symbols: target_currencies
        })
        .to_return(body: file_fixture("historical__api_response.json"))

      response = described_class.call(base_currency, target_currencies, endpoint, date)
      expect(response).to eq({
        "2025-03-24": {
          "base": "EUR",
          "rates": {
            "USD": 1.0824,
            "GBP": 0.83663
          }
        }
      })
    end

    context "and the currencies do not exist" do
      it "returns an error" do
        base_currency, target_currencies, endpoint, date = ["AED", "AFN", "historical", "2025-03-20"]

        stub_request(:get, [described_class::BASE_URL, date].join("/"))
          .with(query: {
            base: base_currency,
            symbols: target_currencies
          })
          .to_return(body: { message: "not found" }.to_json)

        response = described_class.call(base_currency, target_currencies, endpoint, date)
        expect(response).to eq({ message: "not found" })
      end
    end
  end

  context "when it is an open range" do
    it "returns the rates" do
      base_currency, target_currencies, endpoint, date = ["EUR", "USD,GBP", "time_series_to_present", "2025-03-20.."]

      stub_request(:get, [described_class::BASE_URL, date].join("/"))
        .with(query: {
          base: base_currency,
          symbols: target_currencies
        })
        .to_return(body: file_fixture("time_series_to_present__api_response.json"))

      response = described_class.call(base_currency, target_currencies, endpoint, date)
      expect(response).to eq(JSON.parse(file_fixture("time_series_to_present__formatted.json"), symbolize_names: true))
    end
  end

  context "when it is a fixed range" do
    it "returns the rates" do
      base_currency, target_currencies, endpoint, date = ["EUR", "USD,GBP", "time_series_to_present", "2025-03-10..2025-03-20"]

      stub_request(:get, [described_class::BASE_URL, date].join("/"))
        .with(query: {
          base: base_currency,
          symbols: target_currencies
        })
        .to_return(body: file_fixture("time_series_fixed__api_response.json"))

      response = described_class.call(base_currency, target_currencies, endpoint, date)
      expect(response).to eq(JSON.parse(file_fixture("time_series_fixed__formatted.json"), symbolize_names: true))
    end
  end
end
