require "spec_helper"

describe Abn::Client do
  let(:instance) { described_class.new("guid") }

  describe "attributes" do
    subject { instance }

    it_should_behave_like "it has attribute", :errors
    it_should_behave_like "it has attribute", :guid
    it_should_behave_like "it has attribute", :proxy
    it_should_behave_like "it has attribute", :client_options
  end

  describe "instance methods" do
    describe "#parse_search_result" do
      let(:data) do
        {
          asic_number: "12345",
          abn: {
            identifier_value: "54321"
          }
        }
      end

      subject { instance.parse_search_result(data) }

      it "should return a hash" do
        expect(subject).to be_kind_of(Hash)
      end

      it "should contain parsed data" do
        expect(subject).to include(acn: "12345", abn: "54321")
      end
    end

    describe "#search" do
      let(:abn) { "26 154 482 283" }
      let(:savon_client) { instance_double(Savon::Client) }

      context "when abn argument is missing" do
        it "adds to errors array and returns" do
          error_message = "No ABN provided."

          expect { instance.search(nil) }.to change(instance, :errors).to([error_message])
        end
      end

      context "when guid attribute is not set" do
        before { instance.guid = nil }

        it "adds to errors array and returns" do
          error_message = "No GUID provided. Please obtain one at - " \
                          "http://www.abr.business.gov.au/Webservices.aspx"

          expect { instance.search(abn) }.to change(instance, :errors).to([error_message])
        end
      end

      context "when preliminary checks pass" do
        before { allow(Savon).to receive(:client).and_return(savon_client) }

        context "when savon request is successful" do
          before do
            dummy_result = {
              abr_search_by_abn_response: {
                abr_payload_search_results: {
                  response: {
                    business_entity: {
                      asic_number: "12345",
                      abn: {
                        identifier_value: "54321"
                      }
                    }
                  }
                }
              }
            }
            response = double("response", body: dummy_result)
            allow(savon_client).to receive(:call).and_return(response)
          end

          it "returns a hash result" do
            expect(instance.search(abn)).to be_kind_of(Hash)
          end

          it "returns parsed data" do
            result = instance.search(abn)
            expect(result).to include(acn: "12345", abn: "54321")
          end
        end

        context "when savon request raises an exception" do
          before { allow(savon_client).to receive(:call).and_raise("Error") }

          it "adds exception message to errors array" do
            expect { instance.search(abn) }.to change(instance, :errors).to(["Error"])
          end
        end
      end
    end

    describe "#search_by_acn" do
      let(:acn) { "123" }
      let(:savon_client) { instance_double(Savon::Client) }
      let(:dummy_response) do
        double("response", body: {
          abr_search_by_asic_response: {
            abr_payload_search_results: {
              response: {
                business_entity: {
                  asic_number: "12345",
                  abn: {
                    identifier_value: "54321"
                  }
                }
              }
            }
          }
        })
      end

      before do
        allow(Savon).to receive(:client).and_return(savon_client)
      end

      context "when acn argument is missing" do
        it "adds to errors array and returns" do
          expect { instance.search_by_acn(nil) }.to \
            change(instance, :errors).from([]).to(["No ACN provided."])
        end
      end

      context "when guid attribute is not set" do
        before { instance.guid = nil }

        it "adds to errors array and returns" do
          error_message = "No GUID provided. Please obtain one at - " \
                          "http://www.abr.business.gov.au/Webservices.aspx"

          expect { instance.search_by_acn(acn) }.to \
            change(instance, :errors).from([]).to([error_message])
        end
      end

      context "when savon request is successful" do
        before { allow(savon_client).to receive(:call).and_return(dummy_response) }

        it "returns a hash result" do
          expect(instance.search_by_acn(acn)).to be_kind_of(Hash)
        end

        it "returns parsed data" do
          result = instance.search_by_acn(acn)
          expect(result).to include(acn: "12345", abn: "54321")
        end
      end

      context "when savon request raises an exception" do
        before { allow(savon_client).to receive(:call).and_raise("Error") }

        it "adds exception message to errors array" do
          expect { instance.search_by_acn(acn) }.to change(instance, :errors).to(["Error"])
        end
      end
    end

    describe "#search_by_name" do
      let(:savon_client) { instance_double(Savon::Client) }
      let(:dummy_result) do
        {
          abr_search_by_name_response: {
            abr_payload_search_results: {
              response: {
                search_results_list: {
                  search_results_record: [
                    {
                      asic_number: "12345",
                      abn: {
                        identifier_value: "54321"
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      end
      let(:response) { double("response", body: dummy_result) }

      before do
        allow(Savon).to receive(:client).and_return(savon_client)
        allow(savon_client).to receive(:call).and_return(response)
      end

      subject { instance.search_by_name("oneflare") }

      context "when savon request is successful" do
        it { is_expected.to be_kind_of(Array) }

        it "returns parsed data" do
          expect(subject.first).to include(acn: "12345", abn: "54321")
        end
      end

      context "when malformed response raises an exception" do
        let(:response) { double("response", body: { foo: :bar }) }

        it "adds exception message to errors array" do
          expect { instance.search_by_name("oneflare") }.to \
            change(instance, :errors)
        end
      end

      context "when savon request raises an exception" do
        before { allow(savon_client).to receive(:call).and_raise("Error") }

        it "adds exception message to errors array" do
          expect { instance.search_by_name("oneflare") }.to \
            change(instance, :errors).to(["Error"])
        end
      end
    end

    describe "#valid?" do
      subject { instance.valid? }

      context "when there are no errors" do
        it { is_expected.to eq(true) }
      end

      context "when there are errors" do
        before { instance.errors << "123" }
        it { is_expected.to eq(false) }
      end
    end
  end
end
