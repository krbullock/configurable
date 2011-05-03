require 'configurable/config_struct'

module Configurable
  VERSION = '1.0.0'

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def configurable_options(*args)
      @_config_defaults = args.extract_options!
      members = if args.empty?
                  @_config_defaults.keys
                else
                  args
                end
      @_config_struct = ConfigStruct::Struct.new(*members)
    end

    def config
      raise NameError, 'use configurable_options to define settings' unless
        @_config_struct
      @_config ||= @_config_struct.new(@_config_defaults)
    end
  end
end
