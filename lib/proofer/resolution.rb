require 'proofer/question_set'

module Proofer
  class Resolution
    attr_accessor :success, :questions, :vendor_resp, :session_id

    def initialize(opts)
      self.success = opts[:success]
      self.vendor_resp = opts[:vendor_resp]
      self.session_id = opts[:session_id]
      questions = opts[:questions]
      if questions && questions.is_a?(Proofer::QuestionSet)
        self.questions = questions
      elsif questions
        self.questions = Proofer::QuestionSet.new(questions)
      end
    end

    def success?
      success == true
    end
  end
end
