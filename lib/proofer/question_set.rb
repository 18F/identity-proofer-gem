require 'forwardable'
require 'proofer/question'
require 'proofer/question_choice'

module Proofer
  class QuestionSet
    include Enumerable
    extend Forwardable
    def_delegators :questions, :each, :<<, :[]

    attr_accessor :questions, :id

    def initialize(questions = [], id = nil)
      self.questions = questions
      self.id = id
    end

    def find_by_key(key)
      questions.find { |question| question.key == key }
    end
  end
end
