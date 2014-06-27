require 'guard'
require 'guard/plugin'

require 'i18n'
require 'sprockets'

require 'guard/sprockets-i18n/context_helper'

# def t(key, options = nil)
#   I18n.t(key, options)
# end

module Guard
  class SprocketsI18n < Plugin

    class << self
      attr_accessor :current_file_key
    end

    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      super

      @dest_dir     = options[:dest_dir]
      @locales      = Array(options[:locales])
      @locales_path = Array(options[:locales_path])
      @assets_path  = Array(options[:assets_path])

      I18n.enforce_available_locales = true # to fix a deprecation warning
      @locales_path.each do |path|
        I18n.load_path << path
      end

      @sprockets_environments = []
      @locales.each do |locale|
        sprockets_env = Sprockets::Environment.new
        sprockets_env.context_class.class_eval do
          include SprocketsI18nContextHelper
        end
        @assets_path.each do |path|
          sprockets_env.append_path path
        end
        @sprockets_environments << [locale, sprockets_env]
      end
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    # def start
    # end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    # def stop
    # end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    # def reload
    # end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    # def run_all
    #   puts "Run alll"
    #   true
    # end

    # Default behaviour on file(s) changes that the Guard plugin watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    # @return [Object] the task result
    #
    def run_on_changes(paths)
      process_paths(paths)
      true
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    # def run_on_additions(paths)
    # end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    # def run_on_modifications(paths)
    # end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    # def run_on_removals(paths)
    # end

    private
    def process_paths(paths)
      original_locale = I18n.locale
      paths.each do |path|
        set_processing_file path
        @sprockets_environments.each do |locale, env|
          I18n.locale = locale
          dest_file = get_locale_filename(locale, path)
          process_sprocket_file(env, path, dest_file)
        end
      end
      set_processing_file ''
      I18n.locale = original_locale
    end

    def get_locale_filename(locale, path)
      inp_ext = File.extname(path)
      out_file = File.basename(path, inp_ext)
      out_file << "-#{locale}"
      out_file << inp_ext
      File.join(@dest_dir, out_file)
    end

    def set_processing_file(path)
      if path.length > 0
        path_ext = File.extname(path)
        path = File.basename(path, path_ext)
      end
      UI.info "Set processing file: #{path.gsub('/', '.')}"
      self.class.current_file_key = path.gsub('/', '.')
    end

    def process_sprocket_file(environment, file, dest_file)
      UI.info "Processing #{file} -> #{dest_file}"
      File.write(dest_file, environment[file])
    rescue => ex
      UI.error "Error processing file: #{ex.message}"
    end
  end
end