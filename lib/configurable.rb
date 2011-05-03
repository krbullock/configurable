require 'configurable/config_struct'

module Configurable
  VERSION = '1.0.0'

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def configurable_options(*args)
      defaults = args.extract_options!
      members = if args.empty?
                  defaults.keys
                else
                  args
                end
      @_config_struct = ConfigStruct::Struct.new(*members)
      const_set(:Config, @_config_struct) unless const_defined? :Config
      @_default_config = @_config_struct.new(defaults)
    end

    def config
      raise NameError, 'use configurable_options to define settings' unless
        @_config_struct
      @_config ||= @_default_config.dup
    end

    def default_config
      raise NameError, 'use configurable_options to define settings' unless
        @_config_struct
      @_default_config
    end
  end
end
