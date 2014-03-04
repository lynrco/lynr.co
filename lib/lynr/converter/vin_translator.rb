module Lynr; module Converter;

  # # `Lynr::Converter::VinTranslator`
  #
  # Provides an interface for converting data codes from DataOne into
  # human readable strings for use in the presentation layer.
  #
  class VinTranslator

    # ## `Lynr::Converter::VinTranslations::DrivetrainTranslations`
    #
    # `Hash` of drive_type codes from DataOne spreadsheet to the readable
    # names of the drivetrain types.
    #
    DrivetrainTranslations = {
      "AWD" => "All Wheel Drive",
      "FWD" => "Front Wheel Drive",
      "RWD" => "Rear Wheel Drive",
    }

    # ## `Lynr::Converter::VinTranslations::FuelTranslations`
    #
    # `Hash` of fuel_type codes from DataOne spreadsheet to the readable
    # names of the fuel types or how the vehicle is powered.
    #
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

    # ## `Lynr::Converter::VinTranslations::TransmissionTranslations`
    #
    # `Hash` of transmission_type codes from DataOne spreadsheet to the readable
    # names of the transmission types.
    #
    TransmissionTranslations = {
      "A"   => "Automatic",
      "CVT" => "Continuously Variable",
      "M"   => "Manual",
    }

    # ## `VinTranslations#drivetrain(drive_type)`
    #
    # Look up `drive_type` and return the name.
    #
    def drivetrain(drive_type)
      DrivetrainTranslations.fetch(drive_type, default=drive_type)
    end

    # ## `VinTranslations#fuel(fuel_type)`
    #
    # Look up `fuel_type` and return the name.
    #
    def fuel(fuel_type)
      FuelTranslations.fetch(fuel_type, default=fuel_type)
    end

    # ## `VinTranslations#transmission_type(transmission_type)`
    #
    # Look up `transmission_type` and return the name.
    #
    def transmission_type(transmission_type)
      TransmissionTranslations.fetch(transmission_type, default=transmission_type)
    end

  end

end; end;
