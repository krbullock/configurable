require 'configurable/core_ext'
require 'configurable/config_struct'

module Configurable
  VERSION = '1.0.0'

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def configurable_options(opts = {})
    end
  end
end
