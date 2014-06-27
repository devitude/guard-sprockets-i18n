module Guard
  module SprocketsI18nContextHelper
    # module ContextHelper
      def t(key, options = {})
        options = options.dup
        # if key starts with . prepend a name of the file
        key = "#{SprocketsI18n.current_file_key}#{key}" if key.length > 0 && key[0] == '.'
        I18n.t(key, options)
      end
    # end
  end
end