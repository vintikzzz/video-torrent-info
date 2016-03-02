require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'rspec'
Dir.chdir File.dirname(File.dirname(__FILE__))
