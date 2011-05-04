require 'configurable/core_ext/extract_options'

module ConfigStruct
  module HashInitializer
    def initialize(*args)
      hash_args = args.extract_options!
      super(*args)
      for k,v in hash_args
        self[k] = v
      end
    end
  end

  class Struct < ::Struct
    def self.new(*args)
      klass = super
      klass.send(:include, HashInitializer)
    end
  end
end
