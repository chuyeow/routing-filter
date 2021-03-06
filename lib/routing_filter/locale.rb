require 'i18n'
require 'routing_filter/base'

module RoutingFilter
  class Locale < Base
    @@include_default_locale = true
    cattr_writer :include_default_locale

    @@case_insensitive_locales = false
    cattr_accessor :case_insensitive_locales

    @@strip_relative_url_root = true
    cattr_accessor :strip_relative_url_root

    class << self
      def include_default_locale?
        @@include_default_locale
      end

      def locales
        @@locales ||= I18n.available_locales.map(&:to_sym)
      end

      def locales=(locales)
        @@locales = locales.map(&:to_sym)
      end

      def locales_pattern
        @@locales_pattern = if @@case_insensitive_locales
          %r{^/(#{self.locales.map { |l| Regexp.escape(l.to_s) }.join('|')})(?=/|$)}i
        else
          %r{^/(#{self.locales.map { |l| Regexp.escape(l.to_s) }.join('|')})(?=/|$)}
        end
      end
    end

    def around_recognize(path, env, &block)
      locale = extract_locale!(path)                 # remove the locale from the beginning of the path

      if self.class.strip_relative_url_root
        # Remove relative_url_root from path if it's there.
        path.sub! %r{^#{ActionController::Base.relative_url_root}}, ''
      end

      params = yield # invoke the given block (calls more filters and finally routing)
      params[:locale] = locale if locale # set recognized locale to the resulting params hash

      params
    end

    def around_generate(*args, &block)
      locale = args.extract_options!.delete(:locale) # extract the passed :locale option
      locale = I18n.locale if locale.nil?            # default to I18n.locale when locale is nil (could also be false)
      locale = nil unless valid_locale?(locale)      # reset to no locale when locale is not valid

      result = yield

      if locale && prepend_locale?(locale)
        url = result.is_a?(Array) ? result.first : result
        prepend_locale!(url, locale)
      end

      result
    end

    protected

      def extract_locale!(path)
        path.sub! self.class.locales_pattern, ''
        $1
      end

      def prepend_locale?(locale)
        self.class.include_default_locale? || !default_locale?(locale)
      end

      def valid_locale?(locale)
        locale && self.class.locales.include?(locale.to_sym)
      end

      def default_locale?(locale)
        locale && locale.to_sym == I18n.default_locale
      end

      def prepend_locale!(url, locale)
        if self.class.strip_relative_url_root
          url.sub!(%r{(^http.?://[^/]*)?(.*)}) {
            "#{$1}/#{locale}#{ActionController::Base.relative_url_root}#{$2}"
          }
        else
          url.sub!(%r{^(http.?://[^/]*)?(.*)}) { "#{$1}/#{locale}#{$2}" }
        end
      end
  end
end
