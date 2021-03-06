require 'minitest/unit'
require 'minitest/autorun'
require 'set'

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
      assert_respond_to @test_class.default_config, :[]
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

  describe 'configurable_options with nested args' do
    before do
      @test_class.instance_eval do
        configurable_options :a => [:b], :c => {:d => 42}
      end
      @struct = @test_class.const_get('Config')
    end

    it 'should create the config struct' do
      refute_equal ::Config, @struct
      assert_equal %w(a c).to_set, @struct.members.to_set
    end

    it 'should create a nested A struct' do
      begin
        a_struct = @struct.const_get('A')
      rescue NameError
        flunk "#{@test_class}::Config::A not found"
      end
      assert a_struct.ancestors.include? ConfigStruct::Struct
    end

    it 'should create a nested C struct' do
      begin
        c_struct = @struct.const_get('C')
      rescue NameError
        flunk "#{@test_class}::Config::C not found"
      end
      assert c_struct.ancestors.include? ConfigStruct::Struct
    end

    it 'should store defaults' do
      defaults = @test_class.default_config
      assert_respond_to defaults, :a
      assert_respond_to defaults.a, :b
      assert_equal nil, defaults.a.b

      assert_respond_to defaults, :c
      assert_respond_to defaults.c, :d
      assert_equal 42, defaults.c.d
    end
  end

  describe 'after configurable_options is called' do
    before do
      @test_class.instance_eval do
        configurable_options :one => 1, :two => nil
      end
    end

    describe 'generated Config class' do
      before do
        @struct = @test_class.const_get('Config')
        refute_equal ::Config, @struct
      end

      it 'should return the default config' do
        assert_respond_to @struct, :defaults
        @defaults = @struct.defaults
        assert_equal 1, @defaults.one
        assert_nil @defaults.two
      end

      it 'should return the same instance as the class default_config' do
        assert_equal @test_class.default_config, @struct.defaults
        assert_equal @test_class.default_config.object_id,
          @struct.defaults.object_id
      end

      it 'should raise an error if you try to reassign to defaults' do
        begin
          @struct.defaults = @struct.new
          flunk 'expected TypeError'
        rescue TypeError
          # passed test if #defaults= raises TypeError
        end
      end
    end

    describe 'an instance' do
      before do
        @test_inst = @test_class.new
      end

      it 'should have its own config' do
        assert @test_inst.config
        @test_inst.config.one = 42
        refute_equal 42, @test_class.config
      end

      it "should defer to the class's default config" do
        assert @test_inst.default_config
        assert_equal @test_class.default_config, @test_inst.default_config
        assert_equal @test_class.default_config.object_id,
          @test_inst.default_config.object_id
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
