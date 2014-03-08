module Lynr; module Converter;

  # # `Lynr::Converter::NumberTranslator`
  #
  # Define methods to translate numberic values for display.
  #
  module NumberTranslator

    # ## `NumberTranslator.delimit(number, delimiter)`
    #
    # Formats `number` such that `delimiter` precedes every third digit
    # when counting from the right of the number. `number` need not be
    # strictly numeric to be processed by this method as it will be pruned
    # down to only digits before being processed.
    #
    def self.delimit(number, delimiter=",")
      return "" if number.nil?
      cleansed = number.gsub(/\D+/, '')
      return "0" if cleansed.length == 0
      cleansed.gsub(/(\d)(?=(\d{3})+(?!\d))/, "\\1#{delimiter}")
    end

    # ## `NumberTranslator#delimit(number, delimiter)`
    #
    # Invoke the Class method of the same name. This method is included as
    # a convenience.
    #
    def delimit(number, delimiter=",")
      NumberTranslator.delimit(number, delimiter)
    end

  end

end; end;
