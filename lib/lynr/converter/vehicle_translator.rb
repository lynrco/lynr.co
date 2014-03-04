module Lynr; module Converter;

  # # `Lynr::Converter::VehicleTranslator`
  #
  # Provides an interface for converting data codes from used for storage into
  # human readable strings for use in the presentation layer.
  #
  class VehicleTranslator

    # ## `VehicleTranslator::ConditionTranslations`
    #
    # `Hash` of translations for vehicle condition field.
    #
    ConditionTranslations = {
      "1" => "Poor Condition",
      "2" => "Fair Condition",
      "3" => "Good Condition",
      "4" => "Excellent Condition",
    }

    # ## `VehicleTranslator#condition(condition_code)`
    #
    # Look up `condition_code` and return the text label/value.
    #
    def condition(condition_code)
      ConditionTranslations.fetch(condition_code, default="Condition")
    end

  end

end; end;
