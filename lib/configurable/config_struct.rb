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

    def initialize_copy(orig)
      super
      for member in members
        self[member] = self[member].dup if self[member].is_a? Struct
      end
    end

    def to_hash
      members.inject({}) do |hsh, k|
        hsh.tap do |h|
          h[k] = if self[k].is_a? Struct
                   self[k].to_hash
                 else
                   self[k]
                 end
        end
      end
    end

    def to_args
      self.to_hash.to_args
    end
  end
end
