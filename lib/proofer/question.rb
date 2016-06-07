module Proofer
  class Question
    attr_accessor :display
    attr_accessor :key
    attr_accessor :choices
    attr_accessor :answer

    def initialize(params)
      params.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end
  end
end
