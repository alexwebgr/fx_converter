# frozen_string_literal: true

require_relative "services/wizard_service"
require_relative "services/frankfurter_service"

base_currency, target_currencies, endpoint, date = WizardService.call.values
pp FrankfurterService.call(base_currency, target_currencies, endpoint, date)
