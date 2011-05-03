require 'minitest/unit'
require 'minitest/autorun'

require 'configurable/config_struct'

describe ConfigStruct do
  before do
    @struct = ConfigStruct::Struct.new(:a)
  end

  it 'should be initialized from keyword args' do
    inst = @struct.new(:a => 42)
    assert_equal 42, inst.a
  end

  it 'should reject unknown keywords' do
    assert_raises(NameError) { @struct.new(:b => 'invalid argument') }
  end

  it 'should override positional args with keyword args' do
    inst = @struct.new(1, :a => 42)
    assert_equal 42, inst.a
  end
end

describe 'ConfigStruct with nested params' do
  it 'should create nested config structs'
end
