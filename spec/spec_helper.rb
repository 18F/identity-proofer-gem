# use local 'lib' dir in include path
$:.unshift File.dirname(__FILE__)+'/../lib'
require 'pp'
require 'dotenv'

Dotenv.load

RSpec.configure do |config|
  #config.run_all_when_everything_filtered = true
  #config.filter_run :focus
  config.color = true

end

require 'proofer'

Dir[File.dirname(__FILE__) + "/support/*.rb"].sort.each { |file| require file }
