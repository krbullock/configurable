require 'configurable/core_ext/extract_options'

# See documentation on ConfigStruct::Struct.
module ConfigStruct
  module HashInitializer #:nodoc:
    def initialize(*args)
      hash_args = args.extract_options!
      super(*args)
      for k,v in hash_args
        self[k] = v
      end
    end
  end

  # A beefed-up version of Ruby's built-in Struct (and in fact a subclass of
  # it). An instance of a ConfigStruct::Struct is created just as you would
  # create a normal struct:
  #
  #     A = ConfigStruct::Struct.new(:a, :b)
  #
  # You can then create an instance of this struct using hash parameters or
  # ordered parameters:
  #
  #     a = A.new(:a => 1, :b => 2)     # => #<struct A a=1, b=2>
  #
  # You can pass values in order simultaneously with hash parameters. Values
  # passed as hash parameters override those passed as normal parameters:
  #
  #     a = A.new(1, 2, :a => 3)        # => #<struct A a=3, b=2>
  #
  # ConfigStruct::Structs also get deeply copied, that is, any member of a
  # ConfigStruct::Struct instance that is also an instance of a
  # ConfigStruct::Struct will get copied recursively:
  #
  #     a = A.new(1, 2)         # => #<struct A a=1, b=2>
  #     b = A.new(3, a)         # => #<struct A a=3, b=#<struct A a=1, b=2>>
  #     c = b.dup
  #     b.object_id == c.object_id      # => false
  #     b.b.object_id == c.b.object_id  # => false
  #
  class Struct < ::Struct
    def self.new(*args) #:nodoc:
      klass = super
      klass.send(:include, HashInitializer)
    end

    # Recursively copies members of the original struct that are also
    # instances of ConfigStruct::Struct.
    def initialize_copy(orig)
      super
      for member in members
        self[member] = self[member].dup if self[member].is_a? Struct
      end
    end

    # Replaces the current values with the given values. Values can be given
    # in order:
    #
    #     A = ConfigStruct::Struct.new(:a, :b)
    #     a = A.new(1, 2)
    #     a.replace(3, 4)               # => #<struct A a=3, b=4>
    #
    # ...or as hash parameters:
    #
    #     a.replace(:a => 3, :b => 4)   # => #<struct A a=3, b=4>
    #
    # As when creating new instances, values given as hash parameters
    # override those given as positional parameters:
    #
    #     a.replace(3, 4, :a => 5)      # => #<struct A a=5, b=4>
    #
    # Any members not given values will be set to nil.
    #
    def replace(*args)
      hash_args = args.extract_options!
      for member, v in members.zip(args)
        replace_member!(member, v)
      end
      for k, v in hash_args
        replace_member!(k, v)
      end
    end

    # Updates the current values from the given values. Values can be
    # given in order:
    #
    #     A = ConfigStruct::Struct.new(:a, :b)
    #     a = A.new(1, 2)               # => #<struct A a=1, b=2>
    #     a.update(3)                   # => #<struct A a=3, b=2>
    #
    # ...or as hash parameters:
    #
    #     a.update(:a => 3)             # => #<struct A a=3, b=2>
    #
    # As when creating new instances, values given as hash parameters
    # override those given as positional parameters:
    #
    #     a.replace(3, :a => 5)         # => #<struct A a=5, b=2>
    #
    def update(*args)
      hash_args = args.extract_options!
      args.each_with_index do |v, i|
        update_member!(i, v)
      end
      for k, v in hash_args
        update_member!(k, v)
      end
    end
    alias merge! update

    # Converts the struct to a hash with string keys. This allows you,
    # for example, to trivially serialize the struct as YAML.
    #
    #     A = ConfigStruct::Struct.new(:a, :b)
    #     A.new(1, 2).to_hash           # => {"a"=>1, "b"=>2}
    #
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

    # Puts config values into an array suitable for expanding into a
    # parameter list. This is for convenience in recursive traversals of
    # a struct instance.
    def to_args
      self.to_hash.to_args
    end


    private

    # member may also be an index
    def replace_member!(member, value) #:nodoc:
      if self[member].is_a? Struct
        raise TypeError,
        'cannot replace a ConfigStruct::Struct with a scalar' unless
          value.respond_to? :to_args
        self[member].replace(*value.to_args)
      else
        self[member] = value
      end
    end

    # member may also be an index
    def update_member!(member, value) #:nodoc:
      if self[member].is_a? Struct
        raise TypeError,
        'cannot replace a ConfigStruct::Struct with a scalar' unless
          value.respond_to? :to_args
        self[member].update(*value.to_args)
      else
        self[member] = value
      end
    end
  end
end
