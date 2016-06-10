require 'proofer/question_set'
require 'proofer/confirmation'
require 'proofer/resolution'

module Proofer
  module Vendor
    class VendorBase
      attr_accessor :applicant

      def initialize(opts = {})
        self.applicant = coerce_applicant opts[:applicant]
      end

      def start(args = nil)
        if args && !applicant
          self.applicant = coerce_applicant(args)
        end
        perform_resolution
      end

      def submit_answers(question_set, session_id)
        raise "#{self} must implement submit_answers() method"
      end

      def coerce_applicant(applicant)
        return if applicant.nil?
        return applicant if applicant.is_a?(Proofer::Applicant)
        coerce_vendor_applicant(applicant)
      end

      def coerce_vendor_applicant(applicant)
        raise "#{self} must implement coerce_vendor_applicant()"
      end

      def perform_resolution
        raise "#{self} must implement perform_resolution"
      end
    end
  end
end
