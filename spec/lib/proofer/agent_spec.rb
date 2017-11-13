require 'spec_helper'

describe Proofer::Agent do
  let(:applicant) do
    Proofer::Applicant.new(
      first_name: 'Some',
      last_name: 'One',
      dob: '19700501',
      ssn: '666123456',
      address1: '1234 Main St',
      city: 'Anytown',
      state: 'KS',
      zipcode: '66666'
    )
  end

  describe '#new' do
    it 'initializes with config' do
      agent = Proofer::Agent.new vendor: :mock
      expect(agent).to be_a Proofer::Agent
    end
  end

  describe '#vendor' do
    it 'reports the current acting vendor' do
      agent = Proofer::Agent.new vendor: :mock
      expect(agent.vendor).to eq :mock
    end

    it 'delegates to vendor' do
      agent = Proofer::Agent.new vendor: :mock
      resolution = agent.start applicant
      expect(resolution.success).to eq true
      expect(resolution.success?).to eq true

      question_set = resolution.questions
      Proofer::Vendor::Mock::ANSWERS.each do |ques, answ|
        question_set.find_by_key(ques).answer = answ
      end
      qa_confirmation = agent.submit_answers question_set
      expect(qa_confirmation.success).to eq true
      expect(qa_confirmation.success?).to eq true

      financials_confirmation = agent.submit_financials ccn: '12345678'
      expect(financials_confirmation.success).to eq true

      phone_confirmation = agent.submit_phone '(555) 555-0000'
      expect(phone_confirmation.success).to eq true

      state_confirmation = agent.submit_state_id(
        state_id_number: '123456789',
        state_id_jurisdiction: 'WA'
      )
      expect(state_confirmation.success).to eq true
    end
  end

  describe '#applicant=' do
    it 'delegates to vendor' do
      agent = Proofer::Agent.new vendor: :mock
      agent.applicant = applicant
      expect(agent.applicant).to eq applicant
    end
  end
end
