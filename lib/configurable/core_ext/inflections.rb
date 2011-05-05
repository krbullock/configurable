# Define some simplified inflection methods on String if they're not already
# defined. Code adapted from Rails' ActiveSupport.
class String
  unless String.respond_to?(:camelize)
    # Turns a_string_like_this into AStringLikeThis.
    def camelize
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end
