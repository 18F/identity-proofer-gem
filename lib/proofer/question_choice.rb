module Proofer
  class QuestionChoice
    attr_accessor :key
    attr_accessor :display

    def initialize(params)
      self.key = params[:key] or raise ArgumentError, ":key required"
      self.display = params[:display] or raise ArgumentError, ":display required"
    end
  end
end
