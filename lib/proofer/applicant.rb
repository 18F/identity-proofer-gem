module Proofer
  class Applicant
    attr_accessor :first_name, :last_name, :middle_name, :gen
    attr_accessor :address1, :address2, :city, :state, :zipcode
    attr_accessor :ssn, :dob, :phone
    attr_accessor :drivers_license_state, :drivers_license_id, :passport_id, :military_id
    attr_accessor :ccn, :mortgage, :home_equity_line, :auto_loan, :bank_acct, :bank_routing

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
