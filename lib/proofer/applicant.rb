module Proofer
  class Applicant
    # these attribute definition are grouped by "category"
    attr_accessor :uuid
    attr_accessor :first_name, :last_name, :middle_name, :gen
    attr_accessor :address1, :address2, :city, :state, :zipcode
    attr_accessor :prev_address1, :prev_address2, :prev_city, :prev_state, :prev_zipcode
    attr_accessor :ssn, :dob, :phone, :email
    attr_accessor :ccn, :mortgage, :home_equity_line, :auto_loan
    attr_accessor :bank_account, :bank_account_type, :bank_routing
    attr_accessor :state_id_jurisdiction, :state_id_number, :state_id_type

    alias bank_acct bank_account

    def initialize(params)
      params.each do |attr, value|
        raise ArgumentError, "Invalid parameter: #{attr}" unless respond_to?(attr)
        instance_variable_set("@#{attr}", value)
      end
    end

    def to_hash
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete('@')] = instance_variable_get(var)
      end
    end
  end
end
