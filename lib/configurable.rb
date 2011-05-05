require 'configurable/config_struct'
require 'configurable/core_ext/extract_options'
require 'configurable/core_ext/inflections'

# Include this module in a class to make it configurable, and declare
# allowed settings with the Macros.configurable_options method:
#
#     require 'configurable'
#     class Doodad
#       include Configurable
#       configurable_options :one, :two, :three,  # keep options in order
#         :one => 1, :two => 'zwei'               # set defaults
#     end
#
# This creates a ConfigStruct::Struct called Doodad::Config, along with
# a frozen instance of it containing the default options accessible with
# the Doodad.default_config method (see ConfigAccessors.default_config).
#
# You can then use Doodad.config (see ConfigAccessors.config) to store
# the configuration for your class. See ConfigStruct::Struct for the
# available methods. The config object is lazily created when
# Doodad.config is called.
#
# Each instance of Doodad can have its own configuration object as well:
#
#     aDoodad = Doodad.new
#     aDoodad.config                    # => a copy of Doodad.config
#     aDoodad.config.one = 'eins'
#     aDoodad.config.one                # => 'eins'
#     Doodad.config.one                 # => 1
#
module Configurable
  VERSION = '1.0.0' #:nodoc:

  def self.included(klass) #:nodoc:
    klass.extend Macros
    klass.extend ConfigAccessors
  end

  # Returns the class' default configuration object.
  def default_config
    self.class.default_config
  end

  # Returns the object's configuration object. This object is lazily
  # created the first time the method is called as a copy of the class's
  # current config.
  def config
    @_config ||= self.class.config.dup
  end


  # Setup macros for classes that include Configurable.
  module Macros

    # Declares the allowed configuration settings and (optionally) their
    # default values. Field names should be passed as symbols. Example:
    #
    #     configurable_options :one, :two
    #
    # To declare options with default settings, you can pass them as
    # hash parameters:
    #
    #     configurable_options :one => 1, :two => 2
    #
    # In Ruby 1.8, this will not preserve the order of the options. To
    # define the options in a specific order _and_ declare defaults for
    # them, declare the field names first and then the defaults:
    #
    #     configurable_options :one, :two, :one => 1
    #
    # Fields not listed in order but that are passed as hash params will
    # be added after all the ordered parameters, in unspecified order:
    #
    #     configurable_options :one, :two, :one => 1, :five => '3 sir'
    #     Config.members # => ["one", "two", "five"]
    #
    def configurable_options(*args)
      @_config_struct, @_default_config =
        create_struct(self, 'Config', *args)
    end


    private

    def create_struct(base, name, *args) #:nodoc:
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

    def config_struct #:nodoc:
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
