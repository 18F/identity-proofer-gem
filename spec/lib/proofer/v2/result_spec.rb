require 'spec_helper'

require 'proofer/v2/result'

describe Proofer::Result do
  describe '#add_error' do
    let(:error) { 'FOOBAR' }
    let(:result) { Proofer::Result.new.add_error(error) }

    it 'returns itself' do
      expect(result).to be_an_instance_of(Proofer::Result)
    end

    it 'adds an error' do
      expect(result.errors.to_a).to eq([error])
    end

    it 'does not add duplicate error' do
      expect(result.add_error(error).errors.to_a).to eq([error])
    end
  end

  describe '#add_message' do
    let(:message) { 'FOOBAR' }
    let(:result) { Proofer::Result.new.add_message(message) }

    it 'returns itself' do
      expect(result).to be_an_instance_of(Proofer::Result)
    end

    it 'adds a message' do
      expect(result.messages.to_a).to eq([message])
    end

    it 'does not add duplicate message' do
      expect(result.add_message(message).messages.to_a).to eq([message])
    end
  end

  describe '#exception?' do
    subject { result.exception? }

    context 'when there is an exception' do
      let(:result) { Proofer::Result.new(exception: StandardError.new) }
      it { is_expected.to eq(true) }
    end
    context 'when there is no exception' do
      let(:result) { Proofer::Result.new }
      it { is_expected.to eq(false) }
    end
  end

  describe '#failed?' do
    subject { result.failed? }

    context 'when there is an error AND an exception' do
      let(:result) { Proofer::Result.new(exception: StandardError.new).add_error('foobar') }
      it { is_expected.to eq(false) }
    end

    context 'when there is an error and no exception' do
      let(:result) { Proofer::Result.new.add_error('foobar') }
      it { is_expected.to eq(true) }
    end

    context 'when there is no error' do
      let(:result) { Proofer::Result.new }
      it { is_expected.to eq(false) }
    end
  end

  describe '#success?' do
    subject { result.success? }

    context 'when there is an error AND an exception' do
      let(:result) { Proofer::Result.new(exception: StandardError.new).add_error('foobar') }
      it { is_expected.to eq(false) }
    end

    context 'when there is an error and no exception' do
      let(:result) { Proofer::Result.new.add_error('foobar') }
      it { is_expected.to eq(false) }
    end

    context 'when there is no error and no exception' do
      let(:result) { Proofer::Result.new }
      it { is_expected.to eq(true) }
    end
  end

  describe 'context' do
    context 'when provided' do
      it 'is present' do
        context = { foo: 'bar' }
        result = Proofer::Result.new
        result.context = context
        expect(result.context).to eq(context)
      end
    end
  end
end
