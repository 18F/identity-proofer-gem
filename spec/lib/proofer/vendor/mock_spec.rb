require 'spec_helper'

require 'proofer/vendor/mock'

describe Proofer::Vendor::Mock do
  let(:applicant) do
    {
      first_name: 'Some',
      last_name: 'One',
      dob: '19700501',
      ssn: '666123456',
      address1: '1234 Main St',
      city: 'Anytown',
      state: 'KS',
      zipcode: '66666'
    }
  end

  describe '#new' do
    it 'initializes cleanly' do
      mocker = described_class.new applicant: applicant

      expect(mocker).to be_a Proofer::Vendor::Mock
      expect(mocker.applicant).to be_a Proofer::Applicant
    end
  end

  describe '#start' do
    it 'begins proofing cycle' do
      mocker = described_class.new
      resolution = mocker.start applicant

      expect(resolution).to be_a Proofer::Resolution
      expect(resolution.success).to eq true
      expect(resolution.session_id).to_not be_nil
      expect(resolution.questions).to be_a Proofer::QuestionSet
    end

    it 'optionally skips KBV' do
      mocker = described_class.new kbv: false
      resolution = mocker.start applicant

      expect(resolution).to be_a Proofer::Resolution
      expect(resolution.success).to eq true
      expect(resolution.session_id).to_not be_nil
      expect(resolution.questions).to be_nil
    end

    it 'fails on Bad first name' do
      mocker = described_class.new
      resolution = mocker.start first_name: 'Bad'

      expect(resolution).to be_a Proofer::Resolution
      expect(resolution.success).to eq false
      expect(resolution.questions).to be_nil
      expect(resolution.errors).to eq(first_name: 'Unverified first name.')
    end

    it 'fails on 6666 SSN' do
      mocker = described_class.new
      resolution = mocker.start ssn: '6666'

      expect(resolution).to be_a Proofer::Resolution
      expect(resolution.success).to eq false
      expect(resolution.questions).to be_nil
      expect(resolution.errors).to eq(ssn: 'Unverified SSN.')
    end
  end

  describe '#submit_answers' do
    it 'submits question/answer set' do
      mocker = described_class.new applicant: applicant
      question_set = mocker.start.questions
      Proofer::Vendor::Mock::ANSWERS.each do |ques, answ|
        question_set.find_by_key(ques).answer = answ
      end
      confirmation = mocker.submit_answers question_set

      expect(confirmation).to be_a Proofer::Confirmation
      expect(confirmation.success).to eq true
    end

    it 'sets confirmation false if wrong answer given' do
      mocker = described_class.new applicant: applicant
      question_set = mocker.start.questions
      Proofer::Vendor::Mock::ANSWERS.each do |ques, answ|
        question_set.find_by_key(ques).answer = answ
      end
      question_set.find_by_key('city').answer = 'GONDOR'
      confirmation = mocker.submit_answers question_set

      expect(confirmation).to be_a Proofer::Confirmation
      expect(confirmation.success).to eq false
    end

    it 'sets confirmation false if missing answer' do
      mocker = described_class.new applicant: applicant
      question_set = mocker.start.questions
      Proofer::Vendor::Mock::ANSWERS.each do |ques, answ|
        question_set.find_by_key(ques).answer = answ
      end
      question_set.find_by_key('city').answer = nil
      confirmation = mocker.submit_answers question_set

      expect(confirmation).to be_a Proofer::Confirmation
      expect(confirmation.success).to eq false
    end
  end

  describe '#submit_financials' do
    [:ccn, :mortgage, :home_equity_line, :auto_loan].each do |finance_type|
      it "succeeds with #{finance_type}" do
        mocker = described_class.new applicant: applicant
        resolution = mocker.start
        confirmation = mocker.submit_financials({ finance_type => '12345678' }, resolution.session_id)

        expect(confirmation.success).to eq true
      end

      it "fails with bad #{finance_type}" do
        mocker = described_class.new applicant: applicant
        resolution = mocker.start
        confirmation = mocker.submit_financials({ finance_type => '00000000' }, resolution.session_id)

        expect(confirmation.success).to eq false
        expect(confirmation.errors).to eq(finance_type => "The #{finance_type} could not be verified.")
      end
    end
  end

  describe '#submit_phone' do
    it 'succeeds with valid number' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_phone('(555) 555-0000', resolution.session_id)

      expect(confirmation.success).to eq true
    end

    it 'succeeds with +1 prefix' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_phone('+1 (555) 555-0000', resolution.session_id)

      expect(confirmation.success).to eq true
    end

    it 'fails with all fives' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_phone('(555) 555-5555', resolution.session_id)

      expect(confirmation.success).to eq false
      expect(confirmation.errors).to eq(phone: 'The phone number could not be verified.')
    end
  end
end
