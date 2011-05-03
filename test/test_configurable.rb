require 'minitest/unit'
require 'minitest/autorun'

require 'configurable'

class ConfigurableTester
  include Configurable
end

class TestConfigurable < MiniTest::Unit::TestCase
end
