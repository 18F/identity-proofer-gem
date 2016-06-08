require 'proofer/question_set'

module Proofer
  class Resolution
    attr_accessor :success
    attr_accessor :questions

    def initialize(opts)
      self.success = opts[:success]
      self.questions = opts[:questions].is_a?(Proofer::QuestionSet) \
        ? opts[:questions] \
        : Proofer::QuestionSet.new(opts[:questions])
    end
  end
end
