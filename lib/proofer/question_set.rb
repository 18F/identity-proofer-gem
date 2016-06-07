require 'proofer/question'
require 'proofer/question_choice'

module Proofer
  class QuestionSet
    include Enumerable
    extend Forwardable
    def_delegators :questions, :each, :<<

    attr_accessor :questions

    def initialize(questions)
      self.questions = questions
    end
  end
end
