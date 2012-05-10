require 'thor'

module Spawngebob
  class CLI < Thor
    include Constants

    desc "start", "start nginx"
    def start
      Runner.boot(options)
    end

    desc "stop", "stop nginx"
    def stop
      Runner.boot(options)
    end

    desc "restart", "restart nginx"
    def restart
      Runner.boot(options)
    end

    desc "reload", "reload nginx"
    def reload
      Runner.boot(options)
    end

    desc "check", "check status of web server"
    def check
      Runner.boot(options)
    end

    desc "configure", "generate conf files"
    def configure
      # create necessary directories if not exist
      NGINX_DIRS.each do |d|
        full_path = File.join(NGINX_PATH, d)

        if !File.exists? full_path
          Utils.say_with_time "Directory #{full_path} does not exist, creating..." do
            FileUtils.mkdir_p(full_path)
          end
        end
      end

      Runner.boot(options)
    end
  end
end
