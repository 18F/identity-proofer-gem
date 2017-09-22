require 'proofer/vendor/vendor_base'
require 'proofer/vendor/mock_response'
require 'securerandom'

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
        report = build_answer_report(question_set, session_id)
        if report.values.include?(false)
          failed_confirmation(MockResponse.new(report: report))
        else
          successful_confirmation(MockResponse.new(report: report))
        end
      end

      def submit_financials(financials, session_id = nil)
        if financials.is_a?(Hash) && !financial_errors(financials).empty?
          failed_confirmation(
            MockResponse.new(session: session_id, reasons: ['Bad number']),
            financial_errors(financials)
          )
        else
          successful_confirmation(
            MockResponse.new(session: session_id, reasons: ['Good number'])
          )
        end
      end

      def submit_phone(phone_number, session_id = nil)
        plain_phone = phone_number.gsub(/\D/, '').gsub(/\A1/, '')
        if plain_phone == '5555555555'
          fail_confirmation_with_bad_phone(session_id)
        else
          successful_confirmation(
            MockResponse.new(session: session_id, reasons: ['Good number'])
          )
        end
      end

      def coerce_vendor_applicant(applicant)
        Proofer::Applicant.new applicant
      end

      # rubocop:disable MethodLength, AbcSize
      def perform_resolution
        uuid = SecureRandom.uuid
        first_name = applicant.first_name
        if first_name =~ /Fail/i
          fail_resolution_with_exception(uuid)
        elsif first_name =~ /Bad/i
          fail_resolution_with_bad_name(uuid)
        elsif applicant.ssn =~ /6666/
          fail_resolution_with_bad_ssn(uuid)
        elsif looks_like_bad_zipcode(applicant)
          fail_resolution_with_bad_zipcode(uuid)
        else
          pass_resolution(uuid)
        end
      end
      # rubocop:enable MethodLength, AbcSize

      # rubocop:disable all
      def build_question_set(_vendor_resp)
        return nil if options[:kbv] == false

        Proofer::QuestionSet.new([
          Proofer::Question.new(
            key: 'city',
            display: 'Where did you live 10 years ago?',
            choices: [
              Proofer::QuestionChoice.new(key: 'Metropolis', display: 'Metropolis'),
              Proofer::QuestionChoice.new(key: 'Gotham', display: 'Gotham'),
              Proofer::QuestionChoice.new(key: 'Gondor', display: 'Gondor'),
              Proofer::QuestionChoice.new(key: 'Hogsmeade', display: 'Hogsmeade'),
              Proofer::QuestionChoice.new(key: 'None of the Above', display: 'None of the Above <-- PASS')
            ]
        ),
          Proofer::Question.new(
            key: 'bear',
            display: 'What bear is best?',
            choices: [
              Proofer::QuestionChoice.new(key: 'black', display: 'Black bear'),
              Proofer::QuestionChoice.new(key: 'polar', display: 'Polar bear'),
              Proofer::QuestionChoice.new(key: 'grizzly', display: 'Grizzly bear'),
              Proofer::QuestionChoice.new(key: 'schools', display: 'There are two schools of thought <-- PASS'),
              Proofer::QuestionChoice.new(key: 'ridiculous', display: 'This is a ridiculous question')
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
              Proofer::QuestionChoice.new(key: 'blue', display: 'Blue <-- PASS'),
              Proofer::QuestionChoice.new(key: 'green', display: 'Green'),
              Proofer::QuestionChoice.new(key: 'red', display: 'Red'),
              Proofer::QuestionChoice.new(key: 'white', display: 'White'),
              Proofer::QuestionChoice.new(key: 'none of the above', display: 'None of the Above')
            ]
        ),
          Proofer::Question.new(
            key: 'speed',
            display: 'What is the airspeed velocity of an unladen swallow?',
            choices: [
              Proofer::QuestionChoice.new(key: '55', display: '55 <-- PASS'),
              Proofer::QuestionChoice.new(key: '100', display: '100'),
              Proofer::QuestionChoice.new(key: 'uhh', display: 'An African or European swallow?')
            ]
        )
        ])
      end
      # rubocop:enable all

      private

      def looks_like_bad_zipcode(applicant)
        applicant.zipcode == '00000' || applicant.prev_zipcode == '00000'
      end

      def fail_confirmation_with_bad_phone(session_id)
        failed_confirmation(
          MockResponse.new(session: session_id, reasons: ['Bad number']),
          phone: 'The phone number could not be verified.'
        )
      end

      def fail_resolution_with_exception(_uuid)
        raise 'Failed to contact proofing vendor'
      end

      def fail_resolution_with_bad_name(uuid)
        failed_resolution(
          MockResponse.new(
            error: 'bad first name', reasons: ['The name was suspicious'],
            normalized_applicant: normalized_applicant
          ),
          uuid,
          first_name: 'Unverified first name.'
        )
      end

      def fail_resolution_with_bad_ssn(uuid)
        failed_resolution(
          MockResponse.new(
            error: 'bad SSN', reasons: ['The SSN was suspicious'],
            normalized_applicant: normalized_applicant
          ),
          uuid,
          ssn: 'Unverified SSN.'
        )
      end

      def fail_resolution_with_bad_zipcode(uuid)
        failed_resolution(
          MockResponse.new(
            normalized_applicant: normalized_applicant,
            error: 'bad address', reasons: ['The ZIP code was suspicious']
          ),
          uuid,
          zipcode: 'Unverified ZIP code.'
        )
      end

      def pass_resolution(uuid)
        successful_resolution(
          MockResponse.new(
            normalized_applicant: normalized_applicant,
            reasons: ['Everything looks good'],
            kbv: 'some questions here'
          ), uuid
        )
      end

      # rubocop:disable Metrics/AbcSize
      def normalized_applicant
        Proofer::Applicant.new(
          first_name: normalize(applicant.first_name),
          last_name: normalize(applicant.last_name),
          address1: normalize(applicant.address1).sub(/ST$/, 'STREET'),
          address2: normalize(applicant.address2),
          city: normalize(applicant.city).sub('ST.', 'SAINT'),
          state: normalize(applicant.state),
          zipcode: normalize(applicant.zipcode).sub(/^(\d\d\d\d\d)$/, '\1-1234')
        )
      end
      # rubocop:enable Metrics/AbcSize

      def normalize(str)
        str ? str.upcase : ''
      end

      def financial_errors(financials)
        errors = financials.each_with_object({}) do |pair, error_hash|
          key, value = pair
          if value == '00000000'
            error_hash[key] = "The #{key} could not be verified."
          end
        end
        unless bank_account_type_valid?(financials)
          errors[:bank_account_type] = 'The bank_account_type could not be verified.'
        end
        errors
      end

      def bank_account_type_valid?(financials)
        return true if financials[:bank_account].nil?
        return false if financials[:bank_account_type].nil?
        return false unless %w[checking savings].include?(financials[:bank_account_type].to_s)
        true
      end

      def build_answer_report(question_set, session_id)
        report = { session: session_id }
        question_set.each do |question|
          key = question.key
          report[key] = if ANSWERS[key] == question.answer
                          true
                        else
                          false
                        end
        end
        report
      end
    end
  end
end
