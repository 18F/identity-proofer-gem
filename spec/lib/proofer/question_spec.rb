require 'spec_helper'

describe Proofer::Question do
  describe '#choices_as_hash' do
    it 'coerces array of objects into simple hash' do
      question = described_class.new(
        choices: [Proofer::QuestionChoice.new(key: 'foo', display: 'bar')]
      )
      expect(question.choices_as_hash).to eq('foo' => 'bar')
    end
  end
end
