require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe ABNSearch::ABN do
  describe "valid? class method" do
    it "should identify a valid ABN" do
      good_abns.each do |abn|
        expect(abn.valid?).to be true
      end
    end

    it "should identify an invalid ABN" do
      bad_abns.each do |abn|
        expect(abn.valid?).to be false
      end
    end
  end

  describe "valid_acn? class method" do
    it "should identify a valid ACN" do
      good_acns.each do |acn|
        expect(acn.valid_acn?).to be true
      end
    end

    it "should identify an invalid ACN" do
      bad_acns.each do |acn|
        expect(acn.valid_acn?).to be false
      end
    end
  end

  describe ABNSearch::ABR do
    describe "sanity check" do
      it "should not attempt to query ABR without a GUID" do
        expect{(good_abns.first.update_from_abr!)}.to raise_error(ArgumentError)
      end

      it "should fail if you use a fake GUID" do
        ABNSearch::ABR.new('fake-guid')
        expect{(good_abns.first.update_from_abr!)}.to raise_error(RuntimeError)
      end
    end
  end

  def good_abns
    [
      ABNSearch::ABN.new({abn: 99124391073}),
      ABNSearch::ABN.new({abn: '99124391073'}),
      ABNSearch::ABN.new({abn: '99 12 439 10 73 '}),
      ABNSearch::ABN.new({abn: '46 110 483 513'}),
    ]
  end

  def bad_abns
    [
      ABNSearch::ABN.new({abn: 9912439107}),
      ABNSearch::ABN.new({abn: 991243910711}),
      ABNSearch::ABN.new({abn: 'tom'}),
      ABNSearch::ABN.new({abn: '99124391072'}),
    ]
  end

  def good_acns
    [
      ABNSearch::ABN.new({acn: 124391073}),
      ABNSearch::ABN.new({acn: '124391073'}),
      ABNSearch::ABN.new({acn: ' 12 439 10 73 '}),
      ABNSearch::ABN.new({acn: '110 483 513'}),
    ]
  end

  def bad_acns
    [
      ABNSearch::ABN.new({acn: 12439107}),
      ABNSearch::ABN.new({acn: 1243910711}),
      ABNSearch::ABN.new({acn: 'tom'}),
      ABNSearch::ABN.new({acn: '124391072'}),
    ]
  end

end
