require 'proofer/vendor/vendor_base'

module Proofer
  module Vendor
    class Mock < VendorBase
      ANSWERS = {
        'city'  => 'None of the Above',
        'color' => 'blue',
        'speed' => '55',
        'quest' => 'proof',
        'bear'  => 'schools'
      }.freeze

      def submit_answers(question_set, session_id = nil)
        report = {}
        question_set.each do |question|
          if !question.answer
            report[question.key] = false
          elsif ANSWERS[question.key] != question.answer
            report[question.key] = false
          else
            report[question.key] = true
          end
        end
        unless report.values.include?(false)
          successful_confirmation(report: report)
        else
          failed_confirmation(report: report)
        end
      end

      def submit_financials(financials, session_id = nil)
        if financials.is_a?(Hash) && financials[:ccn] == '12345678'
          successful_confirmation(ok: true)
        else
          failed_confirmation(ok: false)
        end
      end

      def submit_phone(phone_number, session_id = nil)
        if phone_number == '(555) 555-5555'
          successful_confirmation(ok: true)
        else
          failed_confirmation(ok: false)
        end
      end

      def coerce_vendor_applicant(applicant)
        Proofer::Applicant.new applicant
      end

      def perform_resolution
        if applicant.first_name =~ /Bad/i
          failed_resolution({ error: 'bad first name' }, SecureRandom.uuid)
        elsif applicant.ssn == '6666'
          failed_resolution({ error: 'bad SSN' }, SecureRandom.uuid)
        else
          successful_resolution({ kbv: 'some questions here' }, SecureRandom.uuid)
        end
      end

      def build_question_set(_vendor_resp)
        return nil if options[:kbv] == false

        Proofer::QuestionSet.new([
          Proofer::Question.new(
            key: 'city',
            display: 'Where did you live 10 years ago?',
            choices: [
              Proofer::QuestionChoice.new( key: 'Metropolis', display: 'Metropolis' ),
              Proofer::QuestionChoice.new( key: 'Gotham', display: 'Gotham' ),
              Proofer::QuestionChoice.new( key: 'Gondor', display: 'Gondor' ),
              Proofer::QuestionChoice.new( key: 'Hogsmeade', display: 'Hogsmeade' ),
              Proofer::QuestionChoice.new( key: 'None of the Above', display: 'None of the Above <-- PASS' )
            ]   
          ),
          Proofer::Question.new(
            key: 'bear',
            display: 'What bear is best?',
            choices: [
              Proofer::QuestionChoice.new( key: 'black', display: 'Black bear' ),
              Proofer::QuestionChoice.new( key: 'polar', display: 'Polar bear' ),
              Proofer::QuestionChoice.new( key: 'grizzly', display: 'Grizzly bear' ),
              Proofer::QuestionChoice.new( key: 'schools', display: 'There are two schools of thought <-- PASS' ),
              Proofer::QuestionChoice.new( key: 'ridiculous', display: 'This is a ridiculous question' )
            ]
          ),
          Proofer::Question.new(
            key: 'quest',
            display: 'What is your quest? (PASS: proof)',
          ),
          Proofer::Question.new(
            key: 'color',
            display: 'What is your favorite color?',
            choices: [
              Proofer::QuestionChoice.new( key: 'blue', display: 'Blue <-- PASS' ),
              Proofer::QuestionChoice.new( key: 'green', display: 'Green' ),
              Proofer::QuestionChoice.new( key: 'red', display: 'Red' ),
              Proofer::QuestionChoice.new( key: 'white', display: 'White' ),
              Proofer::QuestionChoice.new( key: 'none of the above', display: 'None of the Above' )
            ]
          ),
          Proofer::Question.new(
            key: 'speed',
            display: 'What is the airspeed velocity of an unladen swallow?',
            choices: [
              Proofer::QuestionChoice.new( key: '55', display: '55 <-- PASS' ),
              Proofer::QuestionChoice.new( key: '100', display: '100' ),
              Proofer::QuestionChoice.new( key: 'uhh', display: 'An African or European swallow?' )
            ]
          )
        ])
      end 
    end
  end
end
