require 'configurable/config_struct'
require 'configurable/core_ext/extract_options'
require 'configurable/core_ext/inflections'

module Configurable
  VERSION = '1.0.0'

  def self.included(klass)
    klass.extend Macros
    klass.extend ConfigAccessors
  end

  def default_config
    self.class.default_config
  end

  def config
    @_config ||= self.class.config.dup
  end


  module Macros
    def configurable_options(*args)
      @_config_struct, @_default_config =
        create_struct(self, 'Config', *args)
    end


    private

    def create_struct(base, name, *args)
      defaults = args.extract_options!
      members = (args + defaults.keys).uniq
      struct = ConfigStruct::Struct.new(*members)
      default_config = struct.new
      base.const_set(name, struct)
      for k, v in defaults
        if v.respond_to?(:to_args)
          substruct, subdefault =
            create_struct(struct, k.to_s.camelize, *(v.to_args))
          default_config[k] = subdefault
        else
          default_config[k] = v
        end
      end
      [struct, default_config.freeze]
    end

    def config_struct
      @_config_struct ||= nil
    end
  end

  module ConfigAccessors
    def config
      raise NameError, 'use configurable_options to define settings' unless
        config_struct
      @_config ||= @_default_config.dup # dup unfreezes
    end

    def default_config
      raise NameError, 'use configurable_options to define settings' unless
        config_struct
      @_default_config
    end
  end
end
