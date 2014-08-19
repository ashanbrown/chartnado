require 'codeclimate-test-reporter'
require 'chartnado/chartnado'

CodeClimate::TestReporter.start

module Rails
  def self.application
    OpenStruct.new(routes: nil, env_config: {})
  end
end
