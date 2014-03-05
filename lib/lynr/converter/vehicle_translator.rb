module Lynr; module Converter;

  # # `Lynr::Converter::VehicleTranslator`
  #
  # Provides an interface for converting data codes from used for storage into
  # human readable strings for use in the presentation layer.
  #
  module VehicleTranslator

    # ## `VehicleTranslator::ConditionTranslations`
    #
    # `Hash` of translations for vehicle condition field.
    #
    ConditionTranslations = {
      "4" => "Excellent Condition",
      "3" => "Good Condition",
      "2" => "Fair Condition",
      "1" => "Poor Condition",
    }

    # ## `VehicleTranslator#condition(condition_code)`
    #
    # Look up `condition_code` and return the text label/value.
    #
    def self.condition(condition_code)
      ConditionTranslations.fetch(condition_code, default="Condition")
    end

    # ## `VehicleTranslations#condition(condition_code)`
    #
    # Delegates to module method of the same name.
    #
    def condition(condition_code)
      VehicleTranslator.condition(condition_code)
    end

  end

end; end;
