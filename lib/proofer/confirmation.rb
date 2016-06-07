module Proofer
  class Confirmation
    attr_accessor :success

    def initialize(opts)
      self.success = opts[:success]
    end
  end
end
