require 'spec_helper'

describe Proofer::QuestionSet do
  let(:question_one) { Proofer::Question.new(key: 'foo', display: 'Foo') }
  let(:question_two) { Proofer::Question.new(key: 'bar', display: 'Bar') }
  let(:question_set) { described_class.new([question_one, question_two]) }

  describe '#new' do
    it 'takes array of Proofer::Questions' do
      expect(question_set.first).to eq question_one
      expect(question_set[1]).to eq question_two
    end
  end

  describe '#find_by_key' do
    it 'selects the correct question' do
      expect(question_set.find_by_key('foo')).to eq question_one
      expect(question_set.find_by_key('bar')).to eq question_two
    end
  end
end
