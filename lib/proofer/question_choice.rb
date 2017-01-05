module Proofer
  class QuestionChoice
    attr_accessor :key
    attr_accessor :display

    def initialize(params)
      self.key = params[:key] or raise ArgumentError, ':key required'
      self.display = params[:display] or raise ArgumentError, ':display required'
    end

    def key_html_safe
      key.gsub(/\W+/, '_')
    end
  end
end
