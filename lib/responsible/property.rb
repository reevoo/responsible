module Responsible
  class Property
    attr_reader :name, :options

    def initialize(name, options)
      unknown_configuration_params = options.keys - %i[delegate to restrict_to doc]
      if unknown_configuration_params.any?
        fail(Responsible::UnknownConfigurationParameter, unknown_configuration_params.join(", "))
      end
      @name, @options = name, options
    end

  end
end
