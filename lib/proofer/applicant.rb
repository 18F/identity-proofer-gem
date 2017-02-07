module Proofer
  class Applicant
    # these attribute definition are grouped by "category"
    attr_accessor :uuid
    attr_accessor :first_name, :last_name, :middle_name, :gen
    attr_accessor :address1, :address2, :city, :state, :zipcode
    attr_accessor :prev_address1, :prev_address2, :prev_city, :prev_state, :prev_zipcode
    attr_accessor :ssn, :dob, :phone, :email
    attr_accessor :drivers_license_state, :drivers_license_id, :passport_id, :military_id
    attr_accessor :ccn, :mortgage, :home_equity_line, :auto_loan, :bank_acct, :bank_routing

    def initialize(params)
      params.each do |attr, value|
        raise ArgumentError, "Invalid parameter: #{attr}" unless respond_to?(attr)
        instance_variable_set("@#{attr}", value)
      end
    end
  end
end
