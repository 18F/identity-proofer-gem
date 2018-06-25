# Identity Proofer Ruby Gem

[![Build Status](https://travis-ci.org/18F/identity-proofer-gem.svg?branch=master)](https://travis-ci.org/18F/identity-proofer-gem)
[![security](https://hakiri.io/github/18F/identity-proofer-gem/master.svg)](https://hakiri.io/github/18F/identity-proofer-gem/master)

## Example proofing session

```ruby
# Create a proofer subclass:
class FooProofer
  vendor_name 'foo:resolution'

  attributes :uuid,
             :first_name,
             :last_name,
             :ssn,
             :dob

  stage :resolution

  proof :foo_proof # this also takes a block

  def foo_proof(applicant, result)
    resolution = get_resolution # resolve the identity

    # if something isn't verified, add an error
    resolution.add_error(:first_name, 'Does not match')

    # if something goes wrong, raise an error
    raise 'failed to auth with the proofing vendor'
  end
end

# Use a vendor subclass
proofer = FooProofer.new.proof(
  uuid: '1234-asdf-5678-qwerty',
  first_name: 'Bob',
  last_name: 'Roberts',
  ssn: '123456789',
  dob: '01/01/1980'
)

proofer.success? # returns true or false
proofer.failed? # returns true or false
proofer.errors # returns a hash of errors, e.g. { first_name: ['Does not match'] }
subject.exception # returns any object that was raised during the `#proof` call
```

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0
> dedication. By submitting a pull request, you are agreeing to comply
> with this waiver of copyright interest.
