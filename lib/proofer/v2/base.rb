require 'set'

module Proofer
  class Base
    class << self

      attr_reader :required_attrs, :proofed_attrs, :proofer

      def required_attributes(*attrs)
        @required_attrs = attrs
      end

      def proofed_attributes(*attrs)
        @proofed_attrs = attrs
      end

      def proof(&block)
        @proofer = block
      end

      # Utility Methods
      def all_verified?(attrs)
        attrs.none? { |_, v| !v }
      end

      def restrict_attrs(applicant, attrs)
        applicant.select { |k| attrs.include?(k) }
      end

      def to_values(applicant)
        applicant.map { |k, v| [k, v[:value]] }.to_h
      end

      def require_attrs(applicant_attrs, required_attrs)
        empty_attrs = (applicant_attrs.select { |_, v| v.nil? || v.empty? }.keys) | (required_attrs - applicant_attrs.keys)
        raise "Required attributes #{empty_attrs.join(', ')} are not present" if empty_attrs.any?
      end
    end

    def proof(applicant)
      reasons = Set.new()
      vendor_attrs = require_attrs(to_values(restrict_attrs(applicant)), )
      begin
        proofed_attrs = self.class.proofer.call(vendor_attrs, reasons)

        # only update the attributes that which the vendor can access
        proofed_applicant = update_applicant(applicant, proofed_attrs)

        self.class.all_verified?(proofed_attrs) ?
          Proofer::Result.success(proofed_applicant, reasons) :
          Proofer::Result.failed(proofed_applicant, reasons)
      rescue Exception => e
        Proofer::Result.error(applicant, e)
      end
    end

    # Restrict the attributes to those specified by the vendor implementation
    # and only provide the values
    def restrict_attrs(applicant)
      self.class.restrict_attrs(applicant, self.class.required_attrs | self.class.proofed_attrs)
    end

    def to_values(applicant)
      self.class.to_values(applicant)
    end

    def require_attrs(applicant)
      self.class.require_attrs(applicant, self.class.required_attrs | self.class.proofed_attrs)
    end

    def update_applicant(applicant, attrs)
      restricted = restrict_attrs(attrs)
      applicant.update(restricted) do |_, v1, v2|
        { value: v1[:value], verified: v2 }
      end
    end
  end
end
