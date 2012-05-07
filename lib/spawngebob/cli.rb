require 'thor'

module Spawngebob
  class CLI < Thor
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
      Runner.boot(options)
    end
  end
end
