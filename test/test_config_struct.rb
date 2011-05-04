require 'minitest/unit'
require 'minitest/autorun'

require 'configurable/config_struct'

describe ConfigStruct::Struct do
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

  it 'should convert to a hash' do
    inst = @struct.new(42)
    assert_equal 42, inst.to_hash['a']
  end

  describe 'replace' do
    before do
      @inst = @struct.new(5)
    end

    it 'should replace values from positional args' do
      @inst.replace(42)
      assert_equal 42, @inst.a
    end

    it 'should replace values from keyword args' do
      @inst.replace(:a => 42)
      assert_equal 42, @inst.a
    end

    it 'should override positional args with keyword args' do
      @inst.replace(42, :a => 3)
      assert_equal 3, @inst.a
    end
  end

  describe 'with a nested ConfigStruct::Struct' do
    before do
      @nested = ConfigStruct::Struct.new(:b)
      @inst = @struct.new(:a => @nested.new(:b => 1))
      @inst.freeze
      @inst.a.freeze
      assert_equal 1, @inst.a.b
    end

    it 'should deep-copy' do
      @copy = @inst.dup
      refute_nil @copy.a
      @copy.a.b = 2
      assert_equal 1, @inst.a.b
    end

    it 'should convert to a hash recursively' do
      assert_kind_of Hash, @inst.to_hash['a']
      assert_equal 1, @inst.to_hash['a']['b']
    end
  end

  describe 'with a nested ::Struct' do
    before do
      @nested = ::Struct.new(:b)
      @inst = @struct.new(:a => @nested.new(1))
      @inst.freeze
      assert_equal 1, @inst.a.b
    end

    it 'should shallow-copy' do
      @copy = @inst.dup
      refute_nil @copy.a
      @copy.a.b = 2
      assert_equal 2, @inst.a.b
    end

    it 'should not convert to a hash recursively' do
      assert_kind_of @nested, @inst.to_hash['a']
      assert_equal 1, @inst.to_hash['a'].b
    end
  end
end
