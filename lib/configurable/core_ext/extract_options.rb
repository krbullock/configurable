# Define Array#extract_options! and associated methods if they're not
# already defined. Code taken from Rails' ActiveSupport.
class Array
  unless [].respond_to? :extract_options!
    # Extracts options from a set of arguments. Removes and returns the last
    # element in the array if it's a hash, otherwise returns a blank hash.
    #
    #   def options(*args)
    #     args.extract_options!
    #   end
    #
    #   options(1, 2)           # => {}
    #   options(1, 2, :a => :b) # => {:a=>:b}
    def extract_options!
      if last.is_a?(Hash) && last.extractable_options?
        pop
      else
        {}
      end
    end
  end

  # Returns the array in a form suitable for expanding into a parameter
  # list, that is, just the array itself.
  def to_args(box = true)
    self
  end
end

class Hash
  unless {}.respond_to? :extractable_options?
    # By default, only instances of Hash itself are extractable.
    # Subclasses of Hash may implement this method and return
    # true to declare themselves as extractable. If a Hash
    # is extractable, Array#extract_options! pops it from
    # the Array when it is the last element of the Array.
    def extractable_options?
      instance_of?(Hash)
    end
  end

  # needed for to_args
  unless {}.respond_to? :symbolize_keys!
    # Destructively convert all keys to symbols, as long as they respond
    # to +to_sym+.
    def symbolize_keys!
      keys.each do |key|
        self[(key.to_sym rescue key) || key] = delete(key)
      end
      self
    end

    def symbolize_keys
      dup.symbolize_keys!
    end
  end

  # Puts the hash into an array suitable for expanding into a parameter
  # list, such that it will be interpreted as keyword parameters if the
  # method you're calling expects that.
  def to_args(box = true)
    args = self.symbolize_keys
    box ? [args] : args
  end
end
