# Define some simplified inflection methods on String if they're not already
# defined. Code adapted from Rails' ActiveSupport.

unless String.respond_to?(:camelize)
  class String
    def camelize
      lower_case_and_underscored_word.to_s.
        gsub(/\/(.?)/) { "::#{$1.upcase}" }.
        gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end
