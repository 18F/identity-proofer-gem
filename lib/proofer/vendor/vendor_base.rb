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
        self.applicant = coerce_applicant(args) if args && !applicant
        perform_resolution
      end

      def submit_answers(_question_set, _session_id)
        raise NotImplementedError, "#{self} must implement submit_answers() method"
      end

      def submit_financials(_financials, _session_id)
        raise NotImplementedError, "#{self} must implement submit_financials() method"
      end

      def submit_phone(_phone_number, _session_id)
        raise NotImplementedError, "#{self} must implement submit_phone() method"
      end

      def submit_state_id(_state_id_data, _session_id)
        raise NotImplementedError, "#{self} must implement submit_state_id() method"
      end

      def coerce_applicant(applicant)
        return if applicant.nil?
        return applicant if applicant.is_a?(Proofer::Applicant)
        coerce_vendor_applicant(applicant)
      end

      def coerce_vendor_applicant(_applicant)
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

      def failed_resolution(vendor_resp, session_id, errors = {})
        Proofer::Resolution.new(
          success: false,
          vendor_resp: vendor_resp,
          session_id: session_id,
          errors: errors
        )
      end

      def build_question_set(_vendor_resp)
        return nil if options[:kbv] == false
        raise NotImplementedError, "#{self} must implement build_question_set"
      end

      def successful_confirmation(vendor_resp)
        Proofer::Confirmation.new success: true, vendor_resp: vendor_resp
      end

      def failed_confirmation(vendor_resp, errors = {})
        Proofer::Confirmation.new success: false, vendor_resp: vendor_resp, errors: errors
      end
    end
  end
end
