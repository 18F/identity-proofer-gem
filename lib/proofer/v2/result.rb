module Proofer
  class Result
    ERROR = :error
    FAILED = :failed
    SUCCESS = :success

    class << self

      private :new

      def error(applicant, error)
        new(status: ERROR, applicant: applicant, error: error)
      end

      def failed(applicant, reasons = Set.new())
        new(status: FAILED, applicant: applicant, reasons: reasons)
      end

      def success(applicant, reasons = Set.new())
        new(status: SUCCESS, applicant: applicant, reasons: reasons)
      end
    end

    attr_reader :status, :applicant, :reasons, :error

    def initialize(status:, applicant:, reasons: Set.new(), error: nil)
      @status = status
      @applicant = applicant
      @reasons = reasons
      @error = error
    end

    def error?
      status == ERROR
    end

    def failed?
      status == FAILED
    end

    def success?
      status == SUCCESS
    end
  end
end
