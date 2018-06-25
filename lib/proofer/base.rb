require 'set'

module Proofer
  class Base
    @vendor_name = nil
    @attributes = []
    @stage = nil

    class << self
      attr_reader :proofer

      def vendor_name(name = nil)
        @vendor_name = name || @vendor_name
      end

      def attributes(*attributes)
        @attributes = attributes.empty? ? @attributes : attributes
      end

      def stage(stage = nil)
        @stage = stage || @stage
      end

      def proof(sym = nil, &block)
        @proofer = sym || block
      end
    end

    def proof(applicant)
      vendor_applicant = restrict_attributes(applicant)
      validate_attributes(vendor_applicant)
      result = Proofer::Result.new
      execute_proof(proofer, vendor_applicant, result)
      result
    rescue StandardError => exception
      Proofer::Result.new(exception: exception)
    end

    private

    def execute_proof(proofer, *args)
      if proofer.is_a? Symbol
        send(proofer, *args)
      else
        instance_exec(*args, &proofer)
      end
    end

    def restrict_attributes(applicant)
      applicant.select { |attribute| attributes.include?(attribute) }
    end

    def validate_attributes(applicant)
      empty_attributes = applicant.select { |_, attribute| blank?(attribute) }.keys
      missing_attributes = attributes - applicant.keys
      bad_attributes = (empty_attributes | missing_attributes)
      raise error_message(bad_attributes) if bad_attributes.any?
    end

    def error_message(required_attributes)
      "Required attributes #{required_attributes.join(', ')} are not present"
    end

    def attributes
      self.class.attributes
    end

    def stage
      self.class.stage
    end

    def proofer
      self.class.proofer
    end

    def blank?(val)
      !val || val.empty?
    end
  end
end
