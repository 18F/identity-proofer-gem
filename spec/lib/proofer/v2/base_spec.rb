require 'spec_helper'

require 'proofer/v2/base'

describe Proofer::Base do

  let(:impl) { Class.new(Proofer::Base) }

  let(:applicant) do
    {
      first_name: { value: 'Dave', verified: false },
      last_name: { value: 'Corwin', verified: false },
      dob: { value: '01/01/2000', verified: false },
      ssn: { value: '111111111', verified: false },
    }
  end

  describe '.required_attributes' do
    let(:attributes) { [:foo, :bar] }
    it 'stores the required attributes and exposes them via `required_attrs`' do
      impl.required_attributes(*attributes)
      expect(impl.required_attrs).to eq(attributes)
    end
  end

  describe '.proofed_attributes' do
    let(:attributes) { [:foo, :bar] }
    it 'stores the proofed attributes and exposes them via `proofed_attrs`' do
      impl.proofed_attributes(*attributes)
      expect(impl.proofed_attrs).to eq(attributes)
    end
  end

  describe '.proof' do
    let(:logic) { Proc.new { |a, r| {} } }
    it 'stores the proof logic and exposes it via `proofer`' do
      impl.proof(&logic)
      expect(impl.proofer).to eq(logic)
    end
  end

  describe '.all_verified?' do
    subject { impl.all_verified?(attributes) }

    context 'when all are true' do
      let(:attributes) {{ foo: true, bar: true, baz: true }}
      it { is_expected.to eq(true) }
    end

    context 'when one is false' do
      let(:attributes) {{ foo: true, bar: false, baz: true }}
      it { is_expected.to eq(false) }
    end

    context 'when it is empty' do
      let(:attributes) {{ }}
      it { is_expected.to eq(true) }
    end
  end

  describe '.restrict_attrs' do
    subject { impl.restrict_attrs(applicant, attributes) }

    let(:attributes) { [:last_name, :ssn] }

    it 'is a hash containing only the keys listed in attributes' do
      expect(subject).to eq({
        last_name: { value: 'Corwin', verified: false },
        ssn: { value: '111111111', verified: false },
      })
    end
  end

  describe 'to_values' do
    subject { impl.to_values(applicant) }

    it 'is a hash where the value is just the value' do
      expect(subject).to eq({
        first_name: 'Dave',
        dob: '01/01/2000',
        last_name: 'Corwin' ,
        ssn: '111111111',
      })
    end
  end

  let(:attrs) do
    {
      first_name: 'Dave',
      last_name: 'Corwin',
      ssn: '111111111',
    }
  end

  let(:proofed_attrs) do
    {
      first_name: true,
      last_name: true,
      ssn: true,
    }
  end

  let(:verified_applicant) do
    {
      first_name: { value: 'Dave', verified: true },
      last_name: { value: 'Corwin', verified: true },
      dob: { value: '01/01/2000', verified: false },
      ssn: { value: '111111111', verified: true },
    }
  end

  describe '#proof' do
    before do
      impl.required_attributes :first_name, :last_name
      impl.proofed_attributes :ssn
      impl.proof(&logic)
    end

    context 'when proofing succeeds' do

      let(:proofed_attrs) { { first_name: true, last_name: true, ssn: true } }

      let(:proofed_applicant) { {
        first_name: { value: 'Dave', verified: true },
        last_name: { value: 'Corwin', verified: true },
        dob: { value: '01/01/2000', verified: false },
        ssn: { value: '111111111', verified: true },
      } }

      shared_examples 'a successful proof' do
        it 'succeeds' do
          expect(subject.error?).to eq(false)
          expect(subject.failed?).to eq(false)
          expect(subject.success?).to eq(true)
          expect(subject.applicant).to eq(proofed_applicant)
        end
      end

      context 'without reasons' do

        let(:logic) { Proc.new { |a| proofed_attrs } }

        subject { impl.new().proof(applicant) }

        it_behaves_like 'a successful proof'

        it 'has no reasons' do
          expect(subject.reasons.length).to eq(0)
        end
      end

      context 'with reasons' do
        let(:reasons) { ['foo', 'bar']}
        let(:logic) { Proc.new { |a, r| r.merge(reasons); proofed_attrs } }

        subject { impl.new().proof(applicant) }

        it_behaves_like 'a successful proof'

        it 'has reasons' do
          expect(subject.reasons.to_a).to eq(reasons)
        end
      end
    end

    context 'when proofing fails' do

      let(:proofed_attrs) { { first_name: true, last_name: true, ssn: false } }

      let(:proofed_applicant) { {
        first_name: { value: 'Dave', verified: true },
        last_name: { value: 'Corwin', verified: true },
        dob: { value: '01/01/2000', verified: false },
        ssn: { value: '111111111', verified: false },
      } }

      shared_examples 'a failed proof' do
        it 'succeeds' do
          expect(subject.error?).to eq(false)
          expect(subject.failed?).to eq(true)
          expect(subject.success?).to eq(false)
          expect(subject.applicant).to eq(proofed_applicant)
        end
      end

      context 'without reasons' do

        let(:logic) { Proc.new { |a| proofed_attrs } }

        subject { impl.new().proof(applicant) }

        it_behaves_like 'a failed proof'

        it 'has no reasons' do
          expect(subject.reasons.length).to eq(0)
        end
      end

      context 'with reasons' do
        let(:reasons) { ['foo', 'bar']}
        let(:logic) { Proc.new { |a, r| r.merge(reasons); proofed_attrs } }

        subject { impl.new().proof(applicant) }

        it_behaves_like 'a failed proof'

        it 'has reasons' do
          expect(subject.reasons.to_a).to eq(reasons)
        end
      end
    end

    context 'when proofing errors' do

      let(:logic) { Proc.new { |a| raise 'Oh Snap!' } }

      subject { impl.new().proof(applicant) }

      it 'errors' do
        expect(subject.error?).to eq(true)
        expect(subject.failed?).to eq(false)
        expect(subject.success?).to eq(false)
        expect(subject.reasons.length).to eq(0)
        expect(subject.applicant).to eq(applicant)
      end
    end
  end
end
