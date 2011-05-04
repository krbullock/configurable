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

    def replace(*args)
      hash_args = args.extract_options!
      args.each_with_index do |v, i|
        replace_member!(i, v)
      end
      for k, v in hash_args
        replace_member!(k, v)
      end
    end

    def update(*args)
      hash_args = args.extract_options!
      args.each_with_index do |v, i|
        replace_member!(i, v)
      end
      for k, v in hash_args
        replace_member!(k, v)
      end
    end
    alias merge! update

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


    private

    # member may also be an index
    def replace_member!(member, value)
      if self[member].is_a? Struct
        raise TypeError,
        'cannot replace a ConfigStruct::Struct with a scalar' unless
          value.respond_to? :to_args
        self[member].replace(*value.to_args)
      else
        self[member] = value
      end
    end
  end
end
