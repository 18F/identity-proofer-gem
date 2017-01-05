require 'spec_helper'

describe Proofer::Applicant do
  describe '#new' do
    it 'initializes cleanly' do
      applicant = described_class.new first_name: 'Sue', last_name: 'Me'
      expect(applicant.first_name).to eq 'Sue'
    end

    it 'throws exception with invalid params' do
      expect do
        described_class.new foo: 'bar'
      end.to raise_error ArgumentError
    end
  end
end
