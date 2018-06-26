module Proofer
  class Result
    attr_reader :exception
    attr_accessor :context

    def initialize(errors: {}, messages: Set.new, context: {}, exception: nil)
      @errors = errors
      @messages = messages
      @context = context
      @exception = exception
    end

    # rubocop:disable Style/OptionalArguments
    def add_error(key = :base, error)
      (@errors[key] ||= Set.new).add(error)
      self
    end
    # rubocop:enable Style/OptionalArguments

    def add_message(message)
      @messages.add(message)
      self
    end

    def errors
      # Hack city since `transform_values` isn't available until Ruby 2.4
      @errors.transform_values(&:to_a)
    end

    def messages
      @messages.to_a
    end

    def errors?
      @errors.any?
    end

    def exception?
      !@exception.nil?
    end

    def failed?
      !exception? && errors?
    end

    def success?
      !exception? && !errors?
    end

    def to_h
      {
        errors: errors,
        messages: messages,
        exception: exception,
        success: success?,
      }
    end
  end
end
