require 'proofer/vendor/vendor_base'

module Proofer
  module Vendor
    class Mock < VendorBase
      ANSWERS = {
        'city'  => 'NONE OF THE ABOVE',
        'color' => 'green',
        'speed' => '55',
        'quest' => 'proof'
      }.freeze

      def start(args = nil)
        if args && !applicant
          self.applicant = args
        end
        build_verification
      end

      def submit_answers(question_set)
        confirmation = Proofer::Confirmation.new success: true
        question_set.each do |question|
          if !question.answer
            confirmation.success = false
          else
            if ANSWERS[question.key] != question.answer
              confirmation.success = false
            end
          end
        end
        confirmation
      end

      private

      def build_verification
        Proofer::Verification.new success: true, questions: build_questions
      end

      def build_questions
        Proofer::QuestionSet.new([
          Proofer::Question.new(
            key: 'city',
            display: 'Where did you live 10 years ago?',
            choices: [
              Proofer::QuestionChoice.new( key: 'METROPOLIS', display: 'METROPOLIS' ),
              Proofer::QuestionChoice.new( key: 'GOTHAM', display: 'GOTHAM' ),
              Proofer::QuestionChoice.new( key: 'GONDOR', display: 'GONDOR' ),
              Proofer::QuestionChoice.new( key: 'HOGSMEADE', display: 'HOGSMEADE' ),
              Proofer::QuestionChoice.new( key: 'NONE OF THE ABOVE', display: 'NONE OF THE ABOVE <-- PASS' )
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
