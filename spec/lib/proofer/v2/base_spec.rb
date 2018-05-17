require 'spec_helper'

describe Proofer::Base do
  let(:impl) do
    Class.new(Proofer::Base) do
      def hello(applicant, results)
        raise 'Uh oh' unless applicant & results
      end
    end
  end

  let(:applicant) do
    {
      first_name: 'Dave',
      last_name: 'Corwin',
      dob: '01/01/2000',
      ssn: '111111111',
    }
  end

  describe '.attributes' do
    let(:attributes) { %i[foo bar] }
    it 'stores the required attributes and exposes them via `attributes`' do
      impl.attributes(*attributes)
      expect(impl.attributes).to eq(attributes)
    end
  end

  describe '.stage' do
    let(:stage) { :foo }
    it 'stores the stage and exposes it via `stage`' do
      impl.stage(stage)
      expect(impl.stage).to eq(stage)
    end
  end

  describe '.proof' do
    context 'when logic is a block' do
      let(:logic) { proc {} }
      it 'stores the proof logic and exposes it via `proofer`' do
        impl.proof(logic)
        expect(impl.proofer).to eq(logic)
      end
    end

    context 'when logic is a symbol' do
      let(:logic) { :foobar }
      it 'stores the proof logic and exposes it via `proofer`' do
        impl.proof(logic)
        expect(impl.proofer).to eq(logic)
      end
    end
  end

  describe '.vendor_name' do
    let(:name) { 'foobar:baz' }
    it 'stores the name and exposes it via `vendor_name`' do
      impl.vendor_name(name)
      expect(impl.vendor_name).to eq(name)
    end
  end

  describe '#restrict_attributes' do
    let(:attributes) { %i[last_name ssn] }

    before { impl.attributes(*attributes) }

    it 'is a hash containing only the keys listed in attributes' do
      restricted_attributes = impl.new.send(:restrict_attributes, applicant)

      expect(restricted_attributes).to eq(last_name: 'Corwin', ssn: '111111111')
    end
  end

  describe '#validate_attributes' do
    let(:attributes) { %i[first_name last_name] }

    before { impl.attributes(*attributes) }

    subject { impl.new.send(:validate_attributes, applicant) }

    context 'when all attributes are present' do
      let(:applicant) { { first_name: 'Homer', last_name: 'Simpson' } }

      it 'does not raise' do
        expect { subject }.not_to raise_exception
      end
    end

    context 'when attributes are not present' do
      let(:applicant) { { first_name: '' } }

      it 'raises' do
        expect { subject }.
          to raise_exception('Required attributes first_name, last_name are not present')
      end
    end
  end

  describe '#proof' do
    before do
      impl.attributes :first_name, :last_name, :ssn
      impl.proof(logic)
    end

    context 'when required attributes are missing' do
      let(:logic) { proc {} }

      subject { impl.new.proof({}) }

      it 'returns a result with an exception' do
        expect(subject.exception?).to eq(true)
        expect(subject.failed?).to eq(false)
        expect(subject.success?).to eq(false)
        expect(subject.errors).to be_empty
        expect(subject.messages).to be_empty
        expect(subject.exception).not_to be_nil
        expect(subject.exception.message).
          to eq('Required attributes first_name, last_name, ssn are not present')
      end
    end

    context 'when proofing succeeds' do
      let(:logic) { proc {} }

      subject { impl.new.proof(applicant) }

      it 'returns a successful result' do
        expect(subject.exception?).to eq(false)
        expect(subject.failed?).to eq(false)
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
        expect(subject.messages).to be_empty
        expect(subject.exception).to be_nil
      end
    end

    context 'when proofing fails' do
      let(:logic) { proc { |_, result| result.add_error('uh oh') } }

      subject { impl.new.proof(applicant) }

      it 'returns a failed result' do
        expect(subject.exception?).to eq(false)
        expect(subject.failed?).to eq(true)
        expect(subject.success?).to eq(false)
        expect(subject.errors).not_to be_empty
        expect(subject.messages).to be_empty
        expect(subject.exception).to be_nil
      end
    end

    context 'when proofing causes an exception' do
      let(:logic) { proc { raise 'FOOBAR!!!' } }

      subject { impl.new.proof(applicant) }

      it 'returns a result with an exception' do
        expect(subject.exception?).to eq(true)
        expect(subject.failed?).to eq(false)
        expect(subject.success?).to eq(false)
        expect(subject.errors).to be_empty
        expect(subject.messages).to be_empty
        expect(subject.exception).not_to be_nil
      end
    end

    context 'when the logic calls an instance method' do
      let(:logic) do
        proc do |applicant, results|
          hello(applicant, results)
        end
      end

      let(:instance) { impl.new }

      let(:restricted_applicant) do
        instance.send(:restrict_attributes, applicant)
      end

      subject { instance.proof(applicant) }

      it 'returns a successful result' do
        expect(instance).to receive(:hello).
          with(restricted_applicant, an_instance_of(Proofer::Result))
        expect(subject.exception?).to eq(false)
        expect(subject.failed?).to eq(false)
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
        expect(subject.messages).to be_empty
        expect(subject.exception).to be_nil
      end
    end

    context 'when the logic is specified as a symbol' do
      let(:logic) { :hello }

      let(:instance) { impl.new }

      let(:restricted_applicant) do
        instance.send(:restrict_attributes, applicant)
      end

      subject { instance.proof(applicant) }

      it 'returns a successful result' do
        expect(instance).to receive(:hello).
          with(restricted_applicant, an_instance_of(Proofer::Result))
        expect(subject.exception?).to eq(false)
        expect(subject.failed?).to eq(false)
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
        expect(subject.messages).to be_empty
        expect(subject.exception).to be_nil
      end
    end

    context 'when another proofer exists' do
      let(:logic) { proc {} }

      subject { impl.new.proof(applicant) }

      it 'does not affect the other proofer' do
        # rubocop:disable Lint/UselessAssignment
        # This is an explicit check for class-level side effects
        impl2 = Class.new(Proofer::Base) do
          attributes :foobarbaz
        end
        # rubocop:enable Lint/UselessAssignment

        expect(subject.exception?).to eq(false)
        expect(subject.failed?).to eq(false)
        expect(subject.success?).to eq(true)
        expect(subject.errors).to be_empty
        expect(subject.messages).to be_empty
        expect(subject.exception).to be_nil
      end
    end
  end
end
