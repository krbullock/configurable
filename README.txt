= configurable

* http://bitbucket.org/krbullock/configurable

== DESCRIPTION:

Lets you make your Ruby class configurable with a simple mixin.

== FEATURES/PROBLEMS:

* Generic mixin that you can use in any Ruby class. Separates
  configuration of a class from its implementation.

* Settings can be configured from a hash or deserialized from YAML,
  either in a string or a file. (And remember, YAML is a superset of
  JSON!)

* Rejects configuration keys outside those you specify.

* Supports setting defaults on a class which can then be modified for
  each instance of the class.

* Plays nicely with the Singleton module.

== SYNOPSIS:

    require 'configurable'
    class ConfigurableDoodad
      include Configurable

      # Declare the allowed options and their default values
      configurable_options :foo => 'default',
        :bar => {:quux => 42, :wibble => nil},
        :baz => nil
      end
    end

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
