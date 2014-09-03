require 'spec_helper'

describe Responsible::Base do

  context "when a simple property is declare" do
    let(:consumer) { double(:consumer) }
    let(:data) { double(:data) }

    it "raises an error is the property is not implemented" do
      klass = Class.new(described_class) do
        property :not_implemented
      end

      expect {
        klass.new(consumer, data)
      }.to raise_error(Responsible::PropertyNotImplemented)
    end

    it "defines a property if the method exists" do
      klass = Class.new(described_class) do
        property :implemented

        def implemented

        end
      end

      expect {
        klass.new(consumer, data)
      }.to_not raise_error
    end

    it "will create a delegated method (to the 2nd arg) if delegate: true passed in" do
      klass = Class.new(described_class) do
        property :delegated, delegate: true
      end

      expect {
        klass.new(consumer, data)
      }.to_not raise_error

      data = Struct.new(:delegated).new('delegated value')
      klass.new(consumer, data).delegated.should == 'delegated value'
    end

    it "raises an error if defined with unknown param" do
      expect {
        Class.new(described_class) do
          property :delegated, unknown_param: true
        end
      }.to raise_error(Responsible::UnknownConfigurationParameter)
    end

    context "when 'to' parameter passed in" do
      it "raises and error if to method is not defined" do
        klass = Class.new(described_class) do
          property :delegated, delegate: true, to: :delegated?
        end

        data_class = Class.new do
          def delegated?
            true
          end
        end

        klass.new(consumer, data_class.new).delegated.should eq(true)
      end
    end
  end

  describe "#as_json" do

    it "returns a data structure that includes properties without a role" do
      klass = Class.new(described_class) do
        property :no_role

        def no_role
          __data__.no_role
        end
      end

      consumer = double(:consumer, can_see?: true)
      data = double(:data, no_role: true)

      expect(klass.new(consumer, data).as_json).to eq(no_role: true)
    end

    it "returns a data structure that does not include properties that has a role the consumer can't see" do
      klass = Class.new(described_class) do
        property :with_role, restrict_to: :some_role

        def with_role
          __data__.with_role
        end
      end

      consumer = double(:consumer, can_see?: false)
      data = double(:data, with_role: 'besty')
      expect(klass.new(consumer, data).as_json).to eq({})
    end

    it "returns a data structure that includes properties for multipler roles the consumer can see" do
      klass = Class.new(described_class) do
        property :with_external_role,  restrict_to: :external
        property :with_analytics_role, restrict_to: :analytics
        property :with_another_role,   restrict_to: :another_role

        def with_external_role
          __data__.with_external_role
        end

        def with_analytics_role
          __data__.with_analytics_role
        end

        def with_another_role
          __data__.with_another_role
        end
      end


      data = double(:data, with_external_role: 'external', with_analytics_role: 'analytics', with_another_role: 'another')
      consumer = Responsible::Consumer.new(:external, :analytics)

      expect(klass.new(consumer, data).as_json).to eq( { with_external_role: 'external', with_analytics_role: 'analytics' } )
    end
  end

  describe "#data_object_name" do

    let(:consumer) { double(:consumer, can_see?: true) }

    it "allows aliasing of the data method to a more sensible name" do
      klass = Class.new(described_class) do

        data_object_name :my_custom_name
        property :prop

        def prop
          my_custom_name
        end
      end

      expect(klass.new(consumer, 'foo').as_json).to eq({ prop: 'foo' })
    end

  end
end
