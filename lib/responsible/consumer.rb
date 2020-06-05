module Responsible
  class Consumer
    def initialize(*valid_restrictions)
      @valid_restrictions = valid_restrictions
    end

    def can_see?(restrictions, _obj = nil)
      # always allow field with no restrictions to be seen
      restrictions.nil? || (Array(@valid_restrictions) & Array(restrictions)).any?
    end
  end
end
