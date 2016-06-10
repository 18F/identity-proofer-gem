require 'proofer/question_set'

module Proofer
  class Resolution
    attr_accessor :success, :questions, :vendor_resp, :session_id

    def initialize(opts)
      self.success = opts[:success]
      self.vendor_resp = opts[:vendor_resp]
      self.session_id = opts[:session_id]
      if opts[:questions] && opts[:questions].is_a?(Proofer::QuestionSet)
        self.questions = opts[:questions]
      elsif opts[:questions]
        self.questions = Proofer::QuestionSet.new(opts[:questions])
      end
    end
  end
end
