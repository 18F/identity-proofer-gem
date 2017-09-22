# Identity Proofer Ruby Gem

[![Build Status](https://travis-ci.org/18F/identity-proofer-gem.svg?branch=master)](https://travis-ci.org/18F/identity-proofer-gem)
[![security](https://hakiri.io/github/18F/identity-proofer-gem/master.svg)](https://hakiri.io/github/18F/identity-proofer-gem/master)

## Example proofing session

```ruby
applicant = {
  first_name: 'Some',
  last_name: 'One',
  dob: '19700501',
  ssn: '666123456',
  address1: '1234 Main St',
  city: 'St. Somewhere',
  state: 'KS',
  zipcode: '66666'
}


# Initialize a proofer
agent = Proofer::Agent.new(
  applicant: applicant,
  vendor: :mock,
  kbv: false
)

# Start a proofing session
resolution = agent.start(applicant)
resolution.success? # => true
resolution.session_id # => 123abc
resolution.errors # A hash of errors if errors occur

# Submit Financials
# Works with :ccn, :mortgage, :home_equity_line, :auto_loan
confirmation = agent.submit_financials(
  { ccn: '12345678' },
  resolution.session_id
)
confirmation.success? # => true
confirmation.errors # A hash of errors if errors occur

# Submit financials w/ a bank account
confirmation = agent.submit_financials(
  bank_account: '123456789',
  bank_account_type: :savings,
  bank_routing: '987654321',
)
confirmation.success? # => true
confirmation.errors # A hash of errors if errors occur

# Submit Phone
confirmation = agent.submit_phone(
  '2065555000',
  resolution.session_id
)
confirmation.success? # => true
confirmation.errors # A hash of errors if errors occur
```

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0
> dedication. By submitting a pull request, you are agreeing to comply
> with this waiver of copyright interest.
