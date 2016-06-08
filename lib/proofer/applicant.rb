module Proofer
  class Applicant
    attr_accessor :first_name, :last_name, :address1, :address2, :city, :state, :zip, :ssn, :dob, :phone

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
