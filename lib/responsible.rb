require "responsible/consumer"
require "responsible/property"

module Responsible

  class PropertyNotImplemented < StandardError; end
  class UnknownConfigurationParameter < StandardError; end

  class Base

    class << self

      def data_object_name(name)
        alias_method name, :__data__
      end

      def doc(str = nil)
        @doc ||= []
        @doc << str if str
        @doc
      end

      def property(name, options = {})
        property = Property.new(name.to_sym, options)
        properties << property

        delegate_method(property.name, property.options[:to]) if property.options[:delegate] == true
      end

      def properties
        @properties ||= []
      end

      private

      def delegate_method(name, to_delegate)
        define_method name do
          __data__.send(to_delegate || name)
        end
      end
    end

    attr_reader :consumer, :__data__

    def initialize(consumer, data)
      @consumer, @__data__ = consumer, data

      fail Responsible::PropertyNotImplemented, undefined_properties.join(", ") if undefined_properties.any?
    end

    def as_json(_opts = {})
      _properties_.each_with_object({}) do |property, acc|
        acc[property.name] = get_value(property) if consumer.can_see?(property.options[:restrict_to], self)
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

    def get_value(property)
      if property.options[:delegate] == :hash_key
        keys_path = Array(property.options[:to] || property.name)
        __data__.dig(*keys_path)
      else
        public_send(property.name)
      end
    end

    def undefined_properties
      _properties_.reject { |p| p.options[:delegate] == :hash_key }.map(&:name) - methods
    end
  end
end
