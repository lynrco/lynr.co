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

    TransmissionTranslations = {
      "A"   => "Automatic",
      "CVT" => "Continuously Variable",
      "M"   => "Manual",
    }

    def drivetrain(drive_type)
      DrivetrainTranslations.fetch(drive_type, default=drive_type)
    end

    def fuel(fuel_type)
      FuelTranslations.fetch(fuel_type, default=fuel_type)
    end

    def transmission_type(transmission_type)
      TransmissionTranslations.fetch(transmission_type, default=transmission_type)
    end

  end

end; end;
