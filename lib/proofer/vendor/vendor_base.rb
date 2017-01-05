require 'proofer/question_set'
require 'proofer/confirmation'
require 'proofer/resolution'

module Proofer
  module Vendor
    class VendorBase
      attr_accessor :applicant
      attr_accessor :options

      def initialize(opts = {})
        self.applicant = coerce_applicant opts[:applicant]
        self.options = opts
      end

      def start(args = nil)
        if args && !applicant
          self.applicant = coerce_applicant(args)
        end
        perform_resolution
      end

      def submit_answers(question_set, session_id)
        raise NotImplementedError, "#{self} must implement submit_answers() method"
      end

      def submit_financials(financials, session_id)
        raise NotImplementedError, "#{self} must implement submit_financials() method"
      end

      def submit_phone(phone_number, session_id)
        raise NotImplementedError, "#{self} must implement submit_phone() method"
      end

      def coerce_applicant(applicant)
        return if applicant.nil?
        return applicant if applicant.is_a?(Proofer::Applicant)
        coerce_vendor_applicant(applicant)
      end

      def coerce_vendor_applicant(applicant)
        raise NotImplementedError, "#{self} must implement coerce_vendor_applicant()"
      end

      def perform_resolution
        raise NotImplementedError, "#{self} must implement perform_resolution"
      end

      def successful_resolution(vendor_resp, session_id)
        Proofer::Resolution.new(
          success: true,
          questions: build_question_set(vendor_resp),
          vendor_resp: vendor_resp,
          session_id: session_id
        )
      end

      def failed_resolution(vendor_resp, session_id)
        Proofer::Resolution.new(
          success: false,
          vendor_resp: vendor_resp,
          session_id: session_id
        )
      end

      def build_question_set(vendor_resp)
        return nil if options[:kbv] == false
        raise NotImplementedError, "#{self} must implement build_question_set"
      end

      def successful_confirmation(vendor_resp)
        Proofer::Confirmation.new success: true, vendor_resp: vendor_resp
      end

      def failed_confirmation(vendor_resp)
        Proofer::Confirmation.new success: false, vendor_resp: vendor_resp
      end
    end
  end
end
