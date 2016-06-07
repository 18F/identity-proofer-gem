require 'proofer/vendor/vendor_base'

module Proofer
  module Vendor
    class Mock < VendorBase
      def start(args = nil)
        if args && !applicant
          self.applicant = args
        end
        build_verification
      end

      def submit_answers(question_set)
        confirmation = Proofer::Confirmation.new success: false
        question_set.each do |question|
          next unless question.answer
          if question.key == 'city'
            if question.answer == 'NONE OF THE ABOVE'
              confirmation.success = true
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
          )   
        ])
      end 
    end
  end
end
