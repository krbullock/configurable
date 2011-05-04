require 'configurable/config_struct'
require 'configurable/core_ext/extract_options'
require 'configurable/core_ext/inflections'

module Configurable
  VERSION = '1.0.0'

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def configurable_options(*args)
      @_config_struct, @_default_config =
        create_struct(self, 'Config', *args)
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


    private

    def create_struct(base, name, *args)
      defaults = args.extract_options!
      members = (args + defaults.keys).uniq
      struct = ConfigStruct::Struct.new(*members)
      default_config = struct.new
      base.const_set(name, struct)
      for k, v in defaults
        if v.respond_to?(:to_hash) and v.respond_to?(:keys)
          substruct, subdefault = create_struct(struct, k.to_s.camelize, v)
          default_config[k] = subdefault
        elsif v.respond_to?(:to_ary)
          substruct, subdefault = create_struct(struct, k.to_s.camelize, *v)
          default_config[k] = subdefault
        else
          default_config[k] = v
        end
      end
      [struct, default_config.freeze]
    end
  end
end
