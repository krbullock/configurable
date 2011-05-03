require 'minitest/unit'
require 'minitest/autorun'

require 'configurable/config_struct'

class TestConfigStruct < MiniTest::Unit::TestCase
  def setup
    @struct = ConfigStruct::Struct.new(:a)
  end

  def test_hash_initialization
    inst = @struct.new(:a => 42)
    assert_equal 42, inst.a
  end

  def test_reject_unknown_members
    assert_raises(NameError) { @struct.new(:b => 'invalid argument') }
  end

  def test_hash_args_override_positional_args
    inst = @struct.new(1, :a => 42)
    assert_equal 42, inst.a
  end
end
