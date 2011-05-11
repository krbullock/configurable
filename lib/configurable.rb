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
  VERSION = '1.0.1' #:nodoc:

  def self.included(klass) #:nodoc:
    klass.extend Macros
    klass.extend ConfigAccessors
  end

  # Returns the class' default configuration object.
  def default_config
    self.class.default_config
  end

  # Returns the object's current configuration object. This object is
  # lazily created the first time the method is called as a copy of the
  # class' current config.
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
    # This creates a new ConfigStruct::Struct (which is a subclass of
    # Ruby's built-in Struct) called Config within the class it's called
    # on. (Thus if you call it within a class called Doodad, the
    # configuration struct will be created as Doodad::Config.)
    #
    # You may also declare options with default settings, which will
    # then be available thru the default_config method on your class
    # (e.g. Doodad.default_config; see documentation on
    # ConfigAccessors.default_config). To declare defaults, pass them as
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
      @_config_struct.extend ConfigStructDefaults
      @_config_struct.defaults = @_default_config
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

  # Accessors for the class' default configuration to add to the
  # generated Config module.
  module ConfigStructDefaults
    # The class' default configuration.
    attr_accessor :defaults
  end

  # Methods to access the class' current configuration and default
  # configuration.
  module ConfigAccessors
    # Returns the class' configuration object. This object is an
    # instance of the class' Config struct (which is a
    # ConfigStruct::Struct created by the Macros.configurable_options
    # method). It is lazily created the first time the method is called
    # as a copy of the default configuration object.
    def config
      raise NameError, 'use configurable_options to define settings' unless
        config_struct
      @_config ||= config_struct.defaults.dup # dup unfreezes
    end

    # Returns the class' default configuration object. This object is a
    # frozen instance of the class' Config struct (which is a
    # ConfigStruct::Struct created by the Macros.configurable_options
    # method).
    def default_config
      raise NameError, 'use configurable_options to define settings' unless
        config_struct
      config_struct.defaults
    end
  end
end
