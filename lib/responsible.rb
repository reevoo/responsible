require 'consumer'

module Responsible

  class PropertyNotImplemented < StandardError; end
  class UnknownConfigurationParameter < StandardError; end

  class Base

    class << self

      def data_object_name name
        alias_method name, :data
      end

      def doc(str=nil)
        @doc ||= []
        @doc << str if str
        @doc
      end

      def property(name, options={})
        unknown_configuration_params = options.keys - [:delegate, :to, :restrict_to, :doc]
        raise(Responsible::UnknownConfigurationParameter, unknown_configuration_params.join(", ")) if unknown_configuration_params.any?

        properties[name.to_sym] = options
        delegate_method(name, options[:to]) if options[:delegate]
      end

      def properties
        @properties ||= {}
      end

      private

      def delegate_method(name, to)
        define_method name do
          data.send(to || name)
        end
      end
    end

    attr_reader :consumer, :data

    def initialize(consumer, data)
      @consumer, @data = consumer, data

      undefined_properties = _properties_.keys - methods

      if undefined_properties.any?
        raise Responsible::PropertyNotImplemented, undefined_properties.join(", ")
      end
    end

    def as_json(opt={})
      result = {}

      _properties_.each do |name, options|
        if consumer.can_see?(options[:restrict_to])
          result[name] = send(name)
        end
      end

      result
    end
    
    private

    def _properties_
      self.class.properties
    end
  end
end