require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe ABNSearch::ABN do
  describe "basic argument checking" do
    it 'raises an error if the abn provided does not smell correct' do
      expect{ ABNSearch::ABN.new('123')}.to raise_error(ArgumentError)
      expect{ ABNSearch::ABN.new('123123123123')}.to raise_error(ArgumentError)
    end

    it 'returns an instance of an abn if everything looks right' do
      expect( ABNSearch::ABN.new('99 124 391 073')).to be_a ABNSearch::ABN
      expect( ABNSearch::ABN.new('99124391073')).to be_a ABNSearch::ABN
      expect( ABNSearch::ABN.new('11111111111')).to be_a ABNSearch::ABN
    end

    it "should have a problem with invalid parameters" do
      expect{ABNSearch::ABN.valid?(nil)}.to       raise_error(ArgumentError)
      expect{ABNSearch::ABN.valid?(Array)}.to     raise_error(ArgumentError)
      expect{ABNSearch::ABN.valid?(Array.new)}.to raise_error(ArgumentError)
    end

    it "should have a problem with invalid parameter type that has a #length of 11" do
      bad_parameter = (1..11).to_a
      expect{ABNSearch::ABN.valid?(bad_parameter)}.to raise_error(ArgumentError)
    end

  end
  describe "valid? class method" do
    it "should identify a valid ABN" do
      expect(ABNSearch::ABN.valid?("12042168743")).to be true
      expect(ABNSearch::ABN.valid?(12042168743)).to   be true
    end

    it "should identify a preformatted valid ABN" do
      expect(ABNSearch::ABN.valid?("12 042 168 743")).to be true
    end

    it "should have a problem with a pre-formatted invalid ABN" do
      expect(ABNSearch::ABN.valid?("12 042 168 744")).to be false
    end

    it "should have a problem with an invalid ABN" do
      expect(ABNSearch::ABN.valid?("12042168744")).to be false
    end
  end

end
