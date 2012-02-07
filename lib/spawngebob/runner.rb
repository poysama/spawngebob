require 'optparse'

module Spawngebob
  class Runner
    include Constants

    def self.boot(args)
      Spawngebob::Constants.const_set('BASE_CONFIG_PATH', File.join(ENV['HOME'], '.spawngebob'))
      Spawngebob::Constants.const_set('NGINX_CONFIG_PATH', File.join(BASE_CONFIG_PATH, 'nginx', '/'))
      Spawngebob::Constants.const_set('NGINX_CONF', File.join(NGINX_CONFIG_PATH, 'conf', 'nginx.conf'))
      Spawngebob::Constants.const_set('NGINX_PID', File.join(NGINX_CONFIG_PATH, 'run', 'nginx.pid'))
      Spawngebob::Constants.const_set('NGINX_BIN', `which nginx 2>/dev/null`.strip)
      Spawngebob::Constants.const_set('KILL_BIN', `which kill 2>/dev/null`.strip)

      self.new(args)
    end

    def initialize(args)
      @options = {}
      @options[:verbose] = false

      optparse = OptionParser.new do |opts|
        opts.banner = "Spawngebob and Patrick!"
        opts.separator "Options:"

        opts.on('-v', '--verbose', 'Verbose') do
          @options[:verbose] = true
        end

        opts.on('-V', '--version', 'Version') do
          puts Spawngebob::VERSION
          exit
        end

        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit
        end
      end

      optparse.parse!

      if args.length == 0
        Utils.say optparse.help
      else
        # create necessary directories if not exist
        NGINX_DIRS.each do |d|
          full_path = File.join(NGINX_CONFIG_PATH, d)

          if !File.exists? full_path
            Utils.say FileUtils.mkdir_p(full_path)
          end
        end

        if Constants.const_defined?("NGINX_BIN")
          if File.exist?(NGINX_CONF) and !File.zero?(NGINX_CONF)
            self.run(args)
          else
            raise "Missing nginx.conf in #{NGINX_CONF}!"
          end
        else
          raise "Nginx is not installed!"
        end

      end
    end

    def run(args)
      case args.shift
      when 'start'
        Spawner.start(@options)
      when 'stop'
        Spawner.stop
      when 'restart'
        Spawner.stop
        Spawner.start(@options)
      when 'check'
        Spawner.check
      when 'configure'
        Compilers::Nginx.new.prepare
      else
        puts "I don't know what to do."
      end
    end
  end
end
