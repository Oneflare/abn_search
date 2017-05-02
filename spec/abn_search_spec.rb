require "spec_helper"

describe ABNSearch do
  let(:instance) { described_class.new }

  describe "instance methods" do
    describe "delegated methods" do
      let(:client) { instance_double(::Abn::Client) }

      before { allow(instance).to receive(:client).and_return(client) }

      describe "#search" do
        it "should delegate to client" do
          expect(client).to receive(:search).with("query_data")
          instance.send(:search, "query_data")
        end
      end

      describe "#search_by_acn" do
        it "should delegate to client" do
          expect(client).to receive(:search_by_acn).with("query_data")
          instance.send(:search_by_acn, "query_data")
        end
      end

      describe "#search_by_name" do
        it "should delegate to client" do
          expect(client).to receive(:search_by_name).with("query_data", ["NSW"], "ALL")
          instance.send(:search_by_name, "query_data", ["NSW"], "ALL")
        end
      end
    end
  end
end