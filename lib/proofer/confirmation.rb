module Proofer
  class Confirmation
    attr_accessor :success, :vendor_resp

    def initialize(opts)
      self.success = opts[:success]
      self.vendor_resp = opts[:vendor_resp]
    end

    def success?
      success == true
    end
  end
end
