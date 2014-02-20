module Responsible
  class Consumer
    def initialize(*valid_restrictions)
      @valid_restrictions = valid_restrictions
    end

    def can_see?(restrictions)
      @valid_restrictions.include?(restrictions)
    end
  end
end