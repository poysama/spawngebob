require 'optparse'

module Spawngebob
  class Runner
    include Constants

    def self.boot(options)
      Spawngebob::Constants.const_set('NGINX_BIN', `which nginx 2>/dev/null`.strip)
      Spawngebob::Constants.const_set('KILL_BIN', `which kill 2>/dev/null`.strip)

      self.new(options) if has_requirements?
    end

    def self.has_requirements?
      # create necessary directories if not exist
      NGINX_DIRS.each do |d|
        full_path = File.join(NGINX_PATH, d)

        if !File.exists? full_path
          Utils.say_with_time "Directory #{full_path} does not exist, creating..." do
            FileUtils.mkdir_p(full_path)
          end
        end
      end

      # check if nginx is installed
      if !Constants.const_defined?("NGINX_BIN")
        Utils.error "Nginx is not installed!"
      end

      # check if nginx.conf exist
      nginx_conf = File.join(NGINX_CONF_PATH, NGINX_CONF)
      if !File.exists?(nginx_conf)
        Utils.error "#{NGINX_CONF} not found in #{NGINX_CONF_PATH}"
      end

      if File.zero?(nginx_conf)
        Utils.error "#{NGINX_CONF} is empty."
      end

      # check if apps.yml exists
      apps_config = File.join(BASE_CONFIG_PATH, CONFIG_FILE)
      if !File.exists?(apps_config)
        Utils.error "#{CONFIG_FILE} not found in #{BASE_CONFIG_PATH}"
      end

      if File.zero?(apps_config)
        Utils.error "#{CONFIG_FILE} is empty."
      end

      true
    end

    def initialize(options)
      @options = options
      @args = ARGV.dup
      @command = ARGV.shift

      self.run(options)
    end

    def run(options)
      case @args.shift
      when 'start'
        system "#{SCRIPT_DIR} start"
      when 'stop'
        system "#{SCRIPT_DIR} stop"
      when 'restart'
        system "#{SCRIPT_DIR} restart"
      when 'check'
        system "#{SCRIPT_DIR} status"
      when 'reload'
        system "#{SCRIPT_DIR} reload"
      when 'configure'
        Compilers::Nginx.new.prepare
      else
        puts "Unknown command! Available commands: {start|stop|restart|check|reload|configure}"
      end
    end
  end
end
