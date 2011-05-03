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
  end

  describe 'configurable_options' do
    before do
      @test_class.instance_eval do
        configurable_options :one => 1, :two => nil
      end
      @struct = @test_class.instance_eval { @_config_struct }
    end

    it 'should create the config struct' do
      assert @struct.ancestors.include? ConfigStruct::Struct
    end
  end
end
