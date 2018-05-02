require 'set'

module Proofer
  class Base
    class << self
      attr_reader :required_attributes, :supported_stage, :proofer, :vendor_name

      def name(name)
        @vendor_name = name
      end

      def attributes(*attributes)
        @required_attributes = attributes
      end

      def stage(stage)
        @supported_stage = stage
      end

      def proof(&block)
        @proofer = block
      end
    end

    def proof(applicant)
      vendor_applicant = restrict_attributes(applicant)
      validate_attributes(vendor_applicant)
      result = Proofer::Result.new
      instance_exec(vendor_applicant, result, &proofer)
      result
    rescue StandardError => exception
      Proofer::Result.new(exception: exception)
    end

    private

    def restrict_attributes(applicant)
      applicant.select { |attribute| required_attributes.include?(attribute) }
    end

    def validate_attributes(applicant)
      empty_attributes = applicant.select { |_, attribute| blank?(attribute) }.keys
      missing_attributes = required_attributes - applicant.keys
      bad_attributes = (empty_attributes | missing_attributes)
      raise error_message(bad_attributes) if bad_attributes.any?
    end

    def error_message(attributes)
      "Required attributes #{attributes.join(', ')} are not present"
    end

    def required_attributes
      self.class.required_attributes
    end

    def supported_stage
      self.class.supported_stage
    end

    def proofer
      self.class.proofer
    end

    def blank?(val)
      !val || val.empty?
    end
  end
end
