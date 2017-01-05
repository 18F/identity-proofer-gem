# use local 'lib' dir in include path
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'pp'
require 'dotenv'

Dotenv.load

RSpec.configure do |config|
  config.color = true
end

require 'proofer'

Dir[File.dirname(__FILE__) + '/support/*.rb'].sort.each { |file| require file }
