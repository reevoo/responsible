module Responsible
  class Property
    attr_reader :name, :options

    def initialize(name, options)
      unknown_configuration_params = options.keys - [:delegate, :to, :restrict_to, :doc]
      raise(Responsible::UnknownConfigurationParameter, unknown_configuration_params.join(", ")) if unknown_configuration_params.any?
      @name, @options = name, options
    end

  end
end
