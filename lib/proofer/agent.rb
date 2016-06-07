module Proofer
  class Agent
    attr_accessor :vendor

    def initialize(opts)
      self.vendor = opts[:vendor] or raise ArgumentError, ":vendor required"
      build_vendor(opts)
    end

    private

    def build_vendor(opts)
      vendor_class_name = vendor.to_s.split('_').map { |w| w.capitalize }.join
      require "proofer/vendor/#{vendor}"
      vendor_class = Object.const_get("Proofer::Vendor::#{vendor_class_name}")
      @_vendor = vendor_class.new opts
    end
  end
end
