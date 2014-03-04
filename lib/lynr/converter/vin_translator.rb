module Lynr; module Converter;

  class VinTranslator

    DrivetrainTranslations = {
      "AWD" => "All Wheel Drive",
      "FWD" => "Front Wheel Drive",
      "RWD" => "Rear Wheel Drive",
    }

    FuelTranslations = {
      "B" => "BioDiesel",
      "D" => "Diesel",
      "F" => "Flex Fuel",
      "G" => "Gasoline",
      "I" => "Plug-in Hybrid",
      "L" => "Electric",
      "N" => "Natural Gas",
      "P" => "Petroleum",
      "Y" => "Gas/Electric Hybrid",
    }

    def drivetrain(drive_type)
      DrivetrainTranslations.fetch(drive_type, default=drive_type)
    end

    def fuel(fuel_type)
      FuelTranslations.fetch(fuel_type, default=fuel_type)
    end

  end

end; end;
