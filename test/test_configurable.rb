require 'minitest/unit'
require 'minitest/autorun'

require 'configurable'

describe Configurable do
  before do
    @test_class = Class.new
    @test_class.instance_eval do
      include Configurable
    end
  end

  describe 'before configurable_options is called' do
    describe 'config' do
      it 'should raise NameError' do
        assert_raises(NameError) { @test_class.config }
      end
    end

    describe 'default_config' do
      it 'should raise NameError' do
        assert_raises(NameError) { @test_class.default_config }
      end
    end
  end

  describe 'configurable_options' do
    before do
      @test_class.instance_eval do
        configurable_options :one => 1, :two => nil
      end
    end

    it 'should create the config struct' do
      begin
        # config struct should be created as <base class>::Config
        @struct = @test_class.const_get('Config')
      rescue NameError
        flunk "#{@test_class}::Config not found"
      end
      refute_equal ::Config, @struct
      assert @struct.ancestors.include? ConfigStruct::Struct
    end

    it 'should store defaults' do
      assert_equal 1, @test_class.default_config[:one]
      assert_nil @test_class.default_config[:two]
    end
  end

  describe 'configurable_options with positional args' do
    before do
      @test_class.instance_eval do
        configurable_options :one, :two,
          :one => 1, :five => 3
      end
      @struct = @test_class.instance_eval { @_config_struct }
    end

    it 'should order the keys the config struct' do
      assert_equal ['one', 'two'], @struct.members[0,2]
    end

    it 'should create members from hash keys at the end' do
      assert_equal 'five', @struct.members.last
    end
  end

  describe 'after configurable_options is called' do
    before do
      @test_class.instance_eval do
        configurable_options :one => 1, :two => nil
      end
    end

    describe 'default_config' do
      before do
        @defaults = @test_class.default_config
      end

      it 'should return the default config' do
        assert_equal 1, @defaults.one
        assert_equal nil, @defaults.two
      end

      it 'should be frozen' do
        assert @defaults.frozen?
        assert_raises(TypeError) { @defaults.one = 42 }
      end
    end

    describe 'config' do
      before do
        @config = @test_class.config
      end

      it 'should not be frozen' do
        refute @config.frozen?
        begin
          @config.one = 42
        rescue TypeError
          flunk "couldn't set config.one"
        end
      end
    end
  end
end
