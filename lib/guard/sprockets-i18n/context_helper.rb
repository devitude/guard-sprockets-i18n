module Guard
  module SprocketsI18nContextHelper

    module ClassMethods
      def i18n_key_prefix=(key_prefix)
        @i18n_key_prefix = key_prefix
      end
      def i18n_key_prefix
        @i18n_key_prefix
      end
    end

    def t(key, options = {})
      options = options.dup
      # if the key starts with '.' then prepend a key prefix to it
      key = "#{self.class.i18n_key_prefix}#{key}" if key.length > 0 && key[0] == '.'
      I18n.t(key, options)
    end
  end
end