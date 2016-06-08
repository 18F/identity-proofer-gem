require 'proofer/question'
require 'proofer/question_choice'

module Proofer
  class QuestionSet
    include Enumerable
    extend Forwardable
    def_delegators :questions, :each, :<<, :[]

    attr_accessor :questions

    def initialize(questions = [])
      self.questions = questions
    end

    def find_by_key(key)
      questions.select { |q| q.key == key }.first
    end
  end
end
