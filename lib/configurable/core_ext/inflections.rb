# Define some simplified inflection methods on String if they're not already
# defined. Code adapted from Rails' ActiveSupport.

unless String.respond_to?(:camelize)
  class String
    def camelize
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end
