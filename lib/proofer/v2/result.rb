module Proofer
  class Result
    attr_reader :errors, :messages, :exception
    attr_accessor :context

    def initialize(errors: Set.new, messages: Set.new, context: {}, exception: nil)
      @errors = errors
      @messages = messages
      @context = context
      @exception = exception
    end

    def add_error(error)
      @errors.add(error)
      self
    end

    def add_message(message)
      @messages.add(message)
      self
    end

    def exception?
      !@exception.nil?
    end

    def failed?
      @exception.nil? && errors.any?
    end

    def success?
      @exception.nil? && errors.empty?
    end
  end
end
