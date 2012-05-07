module Spawngebob
  module Compilers
    class Nginx
      include Constants

      def initialize
        @config_file_path = File.join(BASE_CONFIG_PATH, CONFIG_FILE)
        @container = ''
      end

      def prepare
        @config = ERB.new(File.read(@config_file_path)).result(binding)
        @config = YAML.load(@config)

        if !@config.is_a? Hash
          Utils.error "Garbage #{CONFIG_FILE}! Fix it!"
        else
          compile!
        end
      end

      def compile!
        location_string = ''

        if @config['nginx'].include? 'listen'
          NGINX_DEFAULTS.update(@config['nginx'])
        end

        if @config['nginx'].include? 'port'
          NGINX_DEFAULTS.update(@config['nginx'])
        end

        if @config['nginx']['ssl']
          location_template = NGINX_SSL_LOCATION_TEMPLATE.chomp!
        else
          location_template = NGINX_HTTP_LOCATION_TEMPLATE.chomp!
        end

        # apps
        @config['applications'].each do |k, v|
          s = NGINX_UPSTREAM_TEMPLATE.gsub('%app%', k)
          @container.concat(s.gsub('%port%', "#{v["port"]}"))
        end

        # hosts
        @config['hosts'].each do |k, v|
          v['host'] = [v['host']] unless v['host'].is_a? Array

          v['host'].each do |h|
            # routes
            location_string = ''

            v['routes'].each do |r|
              s = location_template.gsub('%route%', r.first)
              s = s.gsub('%proxy%', r.last)
              location_string.concat(s + "\n")
            end

            if @config['nginx']['ssl_rewrite']
              s = NGINX_SSL_SERVER_TEMPLATE.gsub('%host%', h)
              s = s.gsub('%cert_path%', @config['nginx']['cert_path'])
              s = s.gsub('%key_path%', @config['nginx']['key_path'])
            else
              s = NGINX_SERVER_TEMPLATE.gsub('%host%', h)
            end

            s = s.gsub('%ip%', NGINX_DEFAULTS['listen'])
            s = s.gsub('%port%', NGINX_DEFAULTS['port'].to_s)
            s = s.gsub('%location%', location_string)

            @container.concat(s)
          end
        end

        File.open(File.join(NGINX_CONFD_PATH, 'caresharing.conf'), 'w') do |f|
          Utils.say_with_time "Generating new config file..." do
            f.write(@container)
          end
        end
      end
    end
  end
end
