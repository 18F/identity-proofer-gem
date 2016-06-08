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
      zip: '66666'
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
      verification = mocker.start applicant
      expect(verification).to be_a Proofer::Verification
      expect(verification.success).to eq true
      expect(verification.questions).to be_a Proofer::QuestionSet
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
      question_set.find_by_key('city').answer = 'GONDOR'
      confirmation = mocker.submit_answers question_set
      expect(confirmation).to be_a Proofer::Confirmation
      expect(confirmation.success).to eq false
    end
  end
end
