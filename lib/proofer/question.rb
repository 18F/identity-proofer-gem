module Proofer
  class Question
    attr_accessor :display, :key, :choices, :answer

    def initialize(params)
      params.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end

    def choices_as_hash
      Hash[choices.collect { |choice| [choice.key, choice.display] }]
    end
  end
end
