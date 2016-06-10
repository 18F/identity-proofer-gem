module Proofer
  class Applicant
    attr_accessor :first_name, :last_name, :middle_name
    attr_accessor :address1, :address2, :city, :state, :zipcode
    attr_accessor :ssn, :dob, :phone, :ccn

    def initialize(params)
      params.each do |k, v|
        unless self.respond_to?(k)
          raise ArgumentError, "Invalid parameter: #{k}"
        end
        instance_variable_set("@#{k}", v)
      end
    end
  end
end
