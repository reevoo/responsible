require 'responsible/consumer'
require 'responsible/property'

module Responsible

  class PropertyNotImplemented < StandardError; end
  class UnknownConfigurationParameter < StandardError; end

  class Base

    class << self

      def data_object_name(name)
        alias_method name, :__data__
      end

      def doc(str=nil)
        @doc ||= []
        @doc << str if str
        @doc
      end

      def property(name, options={})
        unknown_configuration_params = options.keys - [:delegate, :to, :restrict_to, :doc]
        raise(Responsible::UnknownConfigurationParameter, unknown_configuration_params.join(", ")) if unknown_configuration_params.any?

        property = Property.new(name.to_sym, options)

        properties << property
        delegate_method(property.name, property.options[:to]) if property.options[:delegate]
      end

      def properties
        @properties ||= []
      end

      private

      def delegate_method(name, to)
        define_method name do
          __data__.send(to || name)
        end
      end
    end

    attr_reader :consumer, :__data__

    def initialize(consumer, data)
      @consumer, @__data__ = consumer, data

      undefined_properties = _properties_.map(&:name) - methods

      if undefined_properties.any?
        raise Responsible::PropertyNotImplemented, undefined_properties.join(", ")
      end
    end

    def as_json(_={})
      _properties_.each_with_object({}) do |property, acc|
        if consumer.can_see?(property.options[:restrict_to], self)
          acc[property.name] = public_send(property.name)
        end
      end
    end

    def data
      warn "[DEPRECATION] #{Kernel.caller.first}\n[DEPRECATION] `data` is deprecated.  Please use `__data__` instead."
      __data__
    end

    private

    def _properties_
      self.class.properties
    end
  end
end
