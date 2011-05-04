require 'configurable/config_struct'
require 'configurable/core_ext/extract_options'

module Configurable
  VERSION = '1.0.0'

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def configurable_options(*args)
      defaults = args.extract_options!
      members = (args + defaults.keys).uniq
      @_config_struct = ConfigStruct::Struct.new(*members)
      const_set(:Config, @_config_struct) unless const_defined? :Config
      @_default_config = @_config_struct.new(defaults).freeze
    end

    def config
      raise NameError, 'use configurable_options to define settings' unless
        @_config_struct
      @_config ||= @_default_config.dup # dup unfreezes
    end

    def default_config
      raise NameError, 'use configurable_options to define settings' unless
        @_config_struct
      @_default_config
    end
  end
end
