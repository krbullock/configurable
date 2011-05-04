= configurable

* http://bitbucket.org/krbullock/configurable

== DESCRIPTION:

Lets you make your Ruby class configurable with a simple mixin.

== FEATURES/PROBLEMS:

* Generic mixin that you can use in any Ruby class (or application).

* Separates handling configuration of a class from its implementation.

* Supports nested settings.

* Rejects configuration keys outside those you specify.

* Supports setting defaults on a class which can then be modified for
  each instance of the class.

* Settings are stored in Structs (well, actually a subclass of Struct),
  so they can be accessed via normal methods calls, or by Symbol or
  String keys.

* Settings (even nested settings) can be serialized to a hash with
  string keys, which means you can also trivially serialize to YAML (or
  JSON).

* Settings (even nested settings) can be loaded from a hash, which means
  you can also trivially deserialize from YAML (and remember, YAML is a
  superset of JSON).

* Plays nicely with the Singleton module.

* Can safely store other kinds of structs as opaque config values. They
  won't get automatically deep-copied.

* Doesn't yet support independent configs for classes and their subclasses.

== SYNOPSIS:

    require 'configurable'
    class Doodad
      include Configurable

      # Declare the allowed options and their default values
      configurable_options :foo => 'default',
        :bar => {:quux => 42, :wibble => nil},
        :baz => nil
    end

    Doodad::Config              # => a ConfigStruct::Struct
    Doodad::Config::Bar         # => another ConfigStruct::Struct

    Doodad.default_config       # => #<struct Doodad::Config
                                #     bar=#<struct Doodad::Config::Bar
                                #          quux=42, wibble=nil>,
                                #     baz=nil,
                                #     foo="default">

    Doodad.config               # => a (deep) copy of default_config,
                                #    ready for use

    Doodad.config.replace(      # replaces config with passed values
      :foo => 'mine',
      :bar => {:quux => 9})

    Doodad.config.replace(      # loads config from a YAML file
      YAML.load('config.yml'))

== REQUIREMENTS:

* Ruby

== INSTALL:

    $ gem install configurable

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(GNU General Public License v2.0)

Copyright (C) 2010 Kevin R. Bullock

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
