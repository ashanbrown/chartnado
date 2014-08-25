require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start

begin
  require 'coveralls'
  Coveralls.wear!
rescue LoadError
end

require 'chartnado'
require 'rspec/mocks'

begin
  require 'pry'
rescue LoadError
end


module Rails
  def self.application
    OpenStruct.new(routes: nil, env_config: {})
  end
end
