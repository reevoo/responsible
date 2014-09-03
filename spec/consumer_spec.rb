require 'spec_helper'

describe Responsible::Consumer do
  context '#can_see?' do
    let(:with_no_restrictions) { described_class.new }
    let(:with_one_restrictions) { described_class.new(:even) }
    let(:with_two_restrictions) { described_class.new(:even, :prime) }

  	it "always return true when no restrictions passed in" do
      expect(with_no_restrictions.can_see?(nil)).to eq(true)
      expect(with_one_restrictions.can_see?(nil)).to eq(true)
      expect(with_two_restrictions.can_see?(nil)).to eq(true)
  	end

    it 'return true if at the restriction is in the valid list' do
      expect(with_no_restrictions.can_see?(:even)).to eq(false)

      expect(with_one_restrictions.can_see?(:even)).to eq(true)
      expect(with_two_restrictions.can_see?(:even)).to eq(true)
    end

    it 'return true if any of the restriction are in the valid list' do
      expect(with_no_restrictions.can_see?([:even, :prime])).to eq(false)
      
      expect(with_one_restrictions.can_see?([:even, :prime])).to eq(true)
      expect(with_two_restrictions.can_see?([:even, :prime])).to eq(true)
    end

    it 'return false if none of the restriction are in the valid list' do
      expect(with_no_restrictions.can_see?(:other)).to eq(false)
      
      expect(with_one_restrictions.can_see?(:other)).to eq(false)
      expect(with_two_restrictions.can_see?(:other)).to eq(false)
    end
  end
end
