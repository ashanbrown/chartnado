require 'codeclimate-test-reporter'
require 'chartnado/chartnado'
require 'rspec/mocks'

begin
  require 'pry'
rescue LoadError
end

CodeClimate::TestReporter.start

module Rails
  def self.application
    OpenStruct.new(routes: nil, env_config: {})
  end
end
