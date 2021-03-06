# frozen_string_literal: true

RSpec.describe Blacklight::NestedOpenStructWithHashAccess do
  describe "#deep_dup" do
    it "preserves the current class" do
      expect(described_class.new(described_class).deep_dup).to be_a_kind_of described_class
    end

    it "preserves the default proc" do
      nested = described_class.new Hash

      copy = nested.deep_dup
      copy.a[:b] = 1
      expect(copy.a[:b]).to eq 1
    end
  end

  describe '#<<' do
    subject { described_class.new(Blacklight::Configuration::Field) }

    it 'includes the key in the hash' do
      subject << :blah
      expect(subject.blah).to have_attributes(key: :blah)
    end
  end
end
