module Proofer
  class Confirmation
    attr_accessor :success, :vendor_resp, :errors

    def initialize(opts)
      self.success = opts[:success]
      self.vendor_resp = opts[:vendor_resp]
      self.errors = opts[:errors] || {}
    end

    def success?
      success == true
    end
  end
end
