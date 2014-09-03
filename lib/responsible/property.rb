module Responsible
  class Property
    attr_reader :name, :options

    def initialize(name, options)
      @name, @options = name, options
    end

  end
end
