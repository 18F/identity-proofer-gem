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
      city: 'St. Somewhere',
      state: 'KS',
      zipcode: '66666',
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
      expect(resolution.errors).to eq({})
      expect(resolution.session_id).to_not be_nil
      expect(resolution.questions).to be_a Proofer::QuestionSet
      expect(resolution.vendor_resp.reasons).to include 'Everything looks good'
    end

    it 'optionally skips KBV' do
      mocker = described_class.new kbv: false
      resolution = mocker.start applicant

      expect(resolution).to be_a Proofer::Resolution
      expect(resolution.success).to eq true
      expect(resolution.errors).to eq({})
      expect(resolution.session_id).to_not be_nil
      expect(resolution.questions).to be_nil
    end

    it 'returns normalized Applicant values' do
      mocker = described_class.new kbv: false
      resolution = mocker.start applicant

      norm_applicant = resolution.vendor_resp.normalized_applicant
      expect(norm_applicant).to be_a Proofer::Applicant
      expect(norm_applicant.city).to eq 'SAINT SOMEWHERE'
      expect(norm_applicant.zipcode).to eq '66666-1234'
      expect(norm_applicant.address1).to eq '1234 MAIN STREET'
      expect(norm_applicant.first_name).to eq 'SOME'
      expect(norm_applicant.last_name).to eq 'ONE'
    end

    it 'fails on Bad first name' do
      mocker = described_class.new
      resolution = mocker.start first_name: 'Bad'

      expect(resolution).to be_a Proofer::Resolution
      expect(resolution.success).to eq false
      expect(resolution.questions).to be_nil
      expect(resolution.errors).to eq(first_name: 'Unverified first name.')
      expect(resolution.vendor_resp.reasons).to include 'The name was suspicious'
    end

    it 'fails on 6666 SSN' do
      mocker = described_class.new
      resolution = mocker.start ssn: '6666'

      expect(resolution).to be_a Proofer::Resolution
      expect(resolution.success).to eq false
      expect(resolution.questions).to be_nil
      expect(resolution.errors).to eq(ssn: 'Unverified SSN.')
      expect(resolution.vendor_resp.reasons).to include 'The SSN was suspicious'
    end

    it 'fails on 00000 zipcode' do
      %i[zipcode prev_zipcode].each do |zipcode|
        mocker = described_class.new
        resolution = mocker.start zipcode => '00000'

        expect(resolution).to be_a Proofer::Resolution
        expect(resolution.success).to eq false
        expect(resolution.questions).to be_nil
        expect(resolution.errors).to eq(zipcode: 'Unverified ZIP code.')
        expect(resolution.vendor_resp.reasons).to include 'The ZIP code was suspicious'
      end
    end

    it 'raises exception on Fail first name' do
      mocker = described_class.new
      expect { mocker.start first_name: 'Fail' }.to raise_exception RuntimeError
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
      expect(confirmation.errors).to eq({})
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
      expect(confirmation.errors).to eq({})
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
      expect(confirmation.errors).to eq({})
    end
  end

  describe '#submit_financials' do
    %i[ccn mortgage home_equity_line auto_loan].each do |finance_type|
      it "succeeds with #{finance_type}" do
        mocker = described_class.new applicant: applicant
        resolution = mocker.start
        confirmation = mocker.submit_financials(
          { finance_type => '12345678' }, resolution.session_id
        )

        expect(confirmation.success).to eq true
        expect(confirmation.errors).to eq({})
      end

      it "fails with bad #{finance_type}" do
        mocker = described_class.new applicant: applicant
        resolution = mocker.start
        confirmation = mocker.submit_financials(
          { finance_type => '00000000' }, resolution.session_id
        )

        expect(confirmation.success).to eq false
        expect(confirmation.errors).
          to eq(finance_type => "The #{finance_type} could not be verified.")
      end
    end

    it 'succeeeds with bank_account' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_financials(
        {
          bank_account: '1234567',
          bank_routing: '1234567',
          bank_account_type: :checking,
        },
        resolution.session_id
      )

      expect(confirmation.success).to eq true
      expect(confirmation.errors).to eq({})
    end

    it 'fails with bad bank_account' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_financials(
        {
          bank_account: '00000000',
          bank_routing: '1234567',
          bank_account_type: :checking,
        },
        resolution.session_id
      )

      expect(confirmation.success).to eq false
      expect(confirmation.errors).to eq(bank_account: 'The bank_account could not be verified.')
    end

    it 'fails with bad bank_account_type' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_financials(
        {
          bank_account: '1234567',
          bank_routing: '1234567',
          bank_account_type: :qwerty,
        },
        resolution.session_id
      )

      expect(confirmation.success).to eq false
      expect(confirmation.errors).
        to eq(bank_account_type: 'The bank_account_type could not be verified.')
    end

    it 'fails if bank_account_type is missing' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_financials(
        {
          bank_account: '1234567',
          bank_routing: '1234567',
        },
        resolution.session_id
      )

      expect(confirmation.success).to eq false
      expect(confirmation.errors).
        to eq(bank_account_type: 'The bank_account_type could not be verified.')
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
      expect(confirmation.errors).to eq({})
    end

    it 'fails with all fives' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_phone('(202) 555-5555', resolution.session_id)

      expect(confirmation.success).to eq false
      expect(confirmation.errors).to eq(phone: 'The phone number could not be verified.')
    end
  end

  describe '#submit_state_id' do
    it 'succeeds with valid state id' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_state_id(
        {
          state_id_number: '123456789',
          state_id_type: 'drivers_license',
          state_id_jurisdiction: 'WA',
        },
        resolution.session_id
      )

      expect(confirmation.success).to eq true
      expect(confirmation.errors).to eq({})
    end

    it 'fails with unsupported juridisction' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_state_id(
        {
          state_id_number: '123456789',
          state_id_type: 'drivers_license',
          state_id_jurisdiction: 'AL',
        },
        resolution.session_id
      )

      expect(confirmation.success).to eq false
      expect(confirmation.errors).
        to eq(state_id_jurisdiction: 'The jurisdiction could not be verified')
    end

    it 'fails with invalid state id' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_state_id(
        {
          state_id_number: '000000000',
          state_id_jurisdiction: 'WA',
          state_id_type: 'drivers_license',
        },
        resolution.session_id
      )

      expect(confirmation.success).to eq false
      expect(confirmation.errors).
        to eq(state_id_number: 'The state ID number could not be verified')
    end

    it 'fails with invalid state id type' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_state_id(
        {
          state_id_number: '123456789',
          state_id_jurisdiction: 'WA',
          state_id_type: 'passport',
        },
        resolution.session_id
      )
      expect(confirmation.success).to eq false
      expect(confirmation.errors).to eq(state_id_type: 'The state ID type could not be verified')
    end

    it 'fails with nil state id type' do
      mocker = described_class.new applicant: applicant
      resolution = mocker.start
      confirmation = mocker.submit_state_id(
        {
          state_id_number: '123456789',
          state_id_jurisdiction: 'WA',
        },
        resolution.session_id
      )
      expect(confirmation.success).to eq false
      expect(confirmation.errors).to eq(state_id_type: 'The state ID type could not be verified')
    end
  end
end
