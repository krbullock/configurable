require 'configurable/config_struct'

module Configurable
  VERSION = '1.0.0'

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def configurable_options(opts = {})
      @_config_struct = ConfigStruct::Struct.new(*opts.keys)
    end

    def config
      raise NameError, 'use configurable_options to define settings' unless
        @_config_struct
      @_config ||= @_config_struct.new
    end
  end
end
