require 'proofer/question_set'

module Proofer
  class Resolution
    attr_accessor :success
    attr_accessor :questions

    def initialize(opts)
      self.success = opts[:success]
      if opts[:questions] && opts[:questions].is_a?(Proofer::QuestionSet)
        self.questions = opts[:questions]
      elsif opts[:questions]
        self.questions = Proofer::QuestionSet.new(opts[:questions])
      end
    end
  end
end
