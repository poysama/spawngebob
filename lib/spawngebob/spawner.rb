module Spawngebob
  class Spawner
    include Constants

    def self.start(opts, flag = false)
      if get_pid && get_worker_pids
        if flag
          Utils.say "nginx #{COLORS[:green]}STARTED!#{COLORS[:blank]}"
        else
          Utils.say "nginx already #{COLORS[:yellow]}EXISTS!#{COLORS[:blank]}"
          check
        end
        exit
      else
        Utils.say_with_time "starting nginx..." do
          Dir.chdir(NGINX_CONFIG_PATH) do
            if opts[:verbose]
              `#{NGINX_BIN} -c #{NGINX_CONF} -p #{NGINX_CONFIG_PATH}`
            else
              `#{NGINX_BIN} -c #{NGINX_CONF} -p #{NGINX_CONFIG_PATH} 2>&1`
            end
          end
        end

        check
      end

      start(opts, true)
    end

    def self.has_pid?
      File.exist?(NGINX_PID) && !File.zero?(NGINX_PID)
    end

    def self.get_pid
      if has_pid?
        File.read(NGINX_PID).chomp!
      else
        Utils.say "#{COLORS[:red]}pid does not exist!#{COLORS[:blank]}"
        false
      end
    end

    def self.stop
      pid = get_pid

      if pid
        Utils.say_with_time "killing #{COLORS[:yellow]}#{pid}#{COLORS[:blank]}..." do
          `#{KILL_BIN} #{pid}`
        end

        if FileUtils.rm_rf(NGINX_PID)
          Utils.say "#{COLORS[:green]}pid removed!#{COLORS[:blank]}"
        end
      else
        Utils.say "#{COLORS[:red]}nginx not running!#{COLORS[:blank]}"
        exit
      end
    end

    def self.get_worker_pids
      worker_pids = `ps ax | grep 'nginx' | grep -v grep | awk '{print $1}'`
    end

    def self.check
      if get_pid && get_worker_pids
        Utils.say "nginx is running: #{COLORS[:green]}#{get_pid}#{COLORS[:blank]}"
      end
    end
  end
end
