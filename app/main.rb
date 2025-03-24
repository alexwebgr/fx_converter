# frozen_string_literal: true

require_relative "services/wizard_service"
require_relative "services/converter_service"

base_currency, target_currencies, endpoint, date = WizardService.call.values
pp ConverterService.call(base_currency, target_currencies, endpoint, date)
