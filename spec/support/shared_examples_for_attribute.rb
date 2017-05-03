shared_examples "it has attribute" do |attribute_name|
  it "should allow setting #{attribute_name}" do
    expect(subject.respond_to?("#{attribute_name}=")).to eq(true)
  end

  it "should allow getting #{attribute_name}" do
    expect(subject.respond_to?(attribute_name)).to eq(true)
  end
end
