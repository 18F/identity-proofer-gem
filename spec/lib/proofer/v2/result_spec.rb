require 'spec_helper'

require 'proofer/v2/result'

describe Proofer::Result do
  let(:applicant) do
    { first_name: 'Dave' }
  end

  describe '.error' do
    it 'is an error' do
      error = 'error'
      result = Proofer::Result.error(applicant, error)

      expect(result.status).to eq(Proofer::Result::ERROR)
      expect(result.error?).to eq(true)
      expect(result.failed?).to eq(false)
      expect(result.success?).to eq(false)
      expect(result.error).to eq(error)
      expect(result.applicant).to eq(applicant)
      expect(result.reasons.length).to eq(0)
    end
  end

  describe '.failed' do
    shared_examples 'it failed' do
      it 'is failed' do
        expect(result.error?).to eq(false)
        expect(result.failed?).to eq(true)
        expect(result.success?).to eq(false)
        expect(result.status).to eq(Proofer::Result::FAILED)
        expect(result.error).to eq(nil)
        expect(result.applicant).to eq(applicant)
      end
    end

    context 'with no reasons' do
      let(:result) { Proofer::Result.failed(applicant) }
      it_behaves_like 'it failed'
      it 'has no reasons' do
        expect(result.reasons.length).to eq(0)
      end
    end

    context 'with reasons' do
      let(:reasons) { %w[foo bar] }
      let(:result) { Proofer::Result.failed(applicant, Set.new(reasons)) }
      it_behaves_like 'it failed'
      it 'has reasons' do
        expect(result.reasons.to_a).to eq(reasons)
      end
    end
  end

  describe '.success' do
    shared_examples 'it succeeded' do
      it 'succeeded' do
        expect(result.error?).to eq(false)
        expect(result.failed?).to eq(false)
        expect(result.success?).to eq(true)
        expect(result.status).to eq(Proofer::Result::SUCCESS)
        expect(result.error).to eq(nil)
        expect(result.applicant).to eq(applicant)
      end
    end

    context 'with no reasons' do
      let(:result) { Proofer::Result.success(applicant) }
      it_behaves_like 'it succeeded'
      it 'has no reasons' do
        expect(result.reasons.length).to eq(0)
      end
    end

    context 'with reasons' do
      let(:reasons) { %w[foo bar] }
      let(:result) { Proofer::Result.success(applicant, Set.new(reasons)) }
      it_behaves_like 'it succeeded'
      it 'has reasons' do
        expect(result.reasons.to_a).to eq(reasons)
      end
    end
  end
end
