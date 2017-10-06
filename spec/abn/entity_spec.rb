require "spec_helper"

describe Abn::Entity do
  let(:instance) { described_class.new }

  describe "attributes" do
    subject { instance }

    it_should_behave_like "it has attribute", :abn
    it_should_behave_like "it has attribute", :acn
    it_should_behave_like "it has attribute", :active_from_date
    it_should_behave_like "it has attribute", :address_state_code
    it_should_behave_like "it has attribute", :address_post_code
    it_should_behave_like "it has attribute", :address_from_date
    it_should_behave_like "it has attribute", :entity_type
    it_should_behave_like "it has attribute", :gst_from_date
    it_should_behave_like "it has attribute", :last_updated
    it_should_behave_like "it has attribute", :legal_name
    it_should_behave_like "it has attribute", :legal_name2
    it_should_behave_like "it has attribute", :main_name
    it_should_behave_like "it has attribute", :name
    it_should_behave_like "it has attribute", :other_trading_name
    it_should_behave_like "it has attribute", :status
    it_should_behave_like "it has attribute", :trading_name
  end

  describe "instance methods" do
    describe "#best_name" do
      subject { instance.best_name }

      context "when legal_name2 is present" do
        before { instance.legal_name2 = "legal_name2" }
        it { is_expected.to eq("legal_name2") }

        # test order of precendence
        context "when legal_name is present" do
          before { instance.legal_name = "legal_name" }
          it { is_expected.to eq("legal_name") }

          context "when other_trading_name is present" do
            before { instance.other_trading_name = "other_trading_name" }
            it { is_expected.to eq("other_trading_name") }

            context "when trading_name is present" do
              before { instance.trading_name = "trading_name" }
              it { is_expected.to eq("trading_name") }

              context "when main_name is present" do
                before { instance.main_name = "main_name" }
                it { is_expected.to eq("main_name") }
              end
            end
          end
        end
      end

      context "when legal_name is present" do
        before { instance.legal_name = "legal_name" }
        it { is_expected.to eq("legal_name") }
      end

      context "when main_name is present" do
        before { instance.main_name = "main_name" }
        it { is_expected.to eq("main_name") }
      end

      context "when other_trading_name is present" do
        before { instance.other_trading_name = "other_trading_name" }
        it { is_expected.to eq("other_trading_name") }
      end

      context "when trading_name is present" do
        before { instance.trading_name = "trading_name" }
        it { is_expected.to eq("trading_name") }
      end

      context "when no valid candidates are present" do
        it { is_expected.to eq("Name unknown") }
      end
    end

    shared_examples_for "it can convert attributes to hash" do
      it { is_expected.to be_kind_of(Hash) }

      it "should return attribute values as hash values" do
        expect(subject).to include(name: "name", trading_name: "trading_name")
      end

      it "should return nil for attributes that are not set" do
        expect(subject).to include(status: nil)
      end
    end

    describe "#to_h" do
      let(:instance) do
        described_class.new(name: "name", trading_name: "trading_name")
      end

      subject { instance.to_h }

      it_should_behave_like "it can convert attributes to hash"
    end

    describe "#as_json" do
      let(:instance) do
        described_class.new(name: "name", trading_name: "trading_name")
      end

      subject { instance.to_h }

      it_should_behave_like "it can convert attributes to hash"
    end

    describe "#instance_values" do
      let(:instance) do
        described_class.new(name: "name", trading_name: "trading_name")
      end

      subject { instance.to_h }

      it_should_behave_like "it can convert attributes to hash"
    end
  end
end
