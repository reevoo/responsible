# Responsible - A Generic Response Builder

[![Build status](https://badge.buildkite.com/425a6d809196afd5bd09a3a1bcbc45ae038668887d27158ba6.svg)](https://buildkite.com/reevoo/responsible)

This is a alternative to [ActiveModel::Serializer](https://github.com/rails-api/active_model_serializers).  Why you may ask, well when we first built this we did not know about it, any then when we saw how they it had been implemented we decided it had too much magic.

So doesn't Responsible have a lot of magic I hear you ask. And the answer is yes but the magic is clearly defined, with the user needed to explicity set all input, have a look and see what I mean.

## Responsible Base

This is the main class used for declaring what the generated JSON will look like.

```ruby
require 'json'
class MySerializer < Responsible::Base
  # data_object_name :number

	property :value_1, delegate: true
  property :value_2

  def value_2
    # number.other[:value]
    __data__.other[:value]
  end
end

class Number
  attr_accessor :other

  def initialize(other)
    @other = other
  end

	def value_1
		'one'
	end
end

data = Number.new(value: 'two')
consumer = Responsible::Consumer.new

MySerializer.new(consumer, data).to_json =>

{
  value_1: 'one',
  value_2: 'two'
}
```

```ruby
# Delegation to hash_key
require 'json'
class MySerializer < Responsible::Base

  property :value_1, delegate: :hash_key
  property :value_2, delegate: :hash_key, to: :value_2_key
  property :value_3, delegate: :hash_key, to: [:nested, :value_3_key]
end


data = { value_1: 'one', value_2_key: 'two', nested: { value_3_key: 'three' } }
consumer = Responsible::Consumer.new

MySerializer.new(consumer, data).to_json =>

{
  value_1: 'one',
  value_2: 'two',
  value_3: 'three'
}
```

### Initialization

It is initialized using a consumer (see below) and a data object that the JSON will be generated from.

### data_object_name

#### Pending code merge
This is a convenience method and allows you to specify an access name for the data object you passed into the initializer (you can also access this object using the ```__data__``` method)

### property

This is how you add items to the json output.  Items are added in the order they are declared and have a number of options that can be set.

#### delegate

If set to `true` the property be automatically read from the data object that was passed in.

If set to `:hash_key` the property will be read from hash object key

#### to

This should be used with delegate if for any reason the method or hash_key on the object does not directly match the name you want to use in the json output

i.e.

```
property :is_king, delegate: true, to: :is_king?
property :is_princess, delegate: :hash_key, to: :is_princess?
```

#### restrict_to

Used in conjunction with the consumer (see below) to determine if the property should be included in the json output at runtime.  This allows a single Responsible builder to be able to output different json data based on a users permissions.


## Consumer

```ruby
require 'json'
class RestrictedSerializer < Responsible::Base
  property :always,delegate: true
  property :two,   delegate: true, restrict_to: [:even, :prime]
  property :three, delegate: true, restrict_to: :prime
  property :four,  delegate: true, restrict_to: :even
end

class Number
  def always; 'here'; end
  def two; 2; end
  def three; 3; end
  def four; 4; end
end

number = Number.new

even_consumer = Responsible::Consumer.new(:even)
RestrictedSerializer.new(even_consumer, number).to_json
# => {always: 'here', two: 2, four: 4}

prime_consumer = Responsible::Consumer.new(:prime)
RestrictedSerializer.new(prime_consumer, number).to_json
# => {always: 'here', two: 2, three: 3}

all_permission_consumer = Responsible::Consumer.new(:prime, :even)
RestrictedSerializer.new(all_permission_consumer, number).to_json
# => {always: 'here', two: 2, three: 3, four: 4}

no_permission_consumer = Responsible::Consumer.new
RestrictedSerializer.new(no_permission_consumer, number).to_json
# => {always: 'here'}
```

The consumer object is responsible for handling permissioning within the system. The base consumer object that is supplied with the gem can be initialized with a list of restrictions that the currently user can see, when passed into a Responsible class, this will limit the properties that are output to JSON to those which either:

* have no restrictions
* Are restricted to one of the values supplied to the consumer object on creation.

### Custom Consumers

Please not that the Consumer class is here as a starting point only and that in a production system we would expect a more complicated set of rules to be required. As such do not limit yourself to the sets of restriction functionality outlined here if it does not meet your usecase

### Release notes:

0.0.3
Ensure that property is always included when no restrictions are specificed.

