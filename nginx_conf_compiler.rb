#!/usr/bin/env ruby
require 'yaml'
require 'erb'
require 'fileutils'

module NginxConfCompiler

  POPO_PATH = ENV['popo_path']
  POPO_TARGET = ENV['popo_target']
  CWD = Dir.pwd
  CONFD_PATH = 'config/conf.d'
  DIRS = ['tmp', 'run', 'logs', CONFD_PATH]
  MIME_TYPES_ORIG_PATH = '/etc/nginx/mime.types'

  def self.prepare
    DIRS.each do |d|
      puts FileUtils.mkdir_p(File.join(CWD, d)) if !File.exists? d
    end

    spawn_tool_path = File.join(POPO_PATH, 'tools', 'spawn')

    if File.exist?(spawn_tool_path) || !File.symlink?(spawn_tool_path)
      FileUtils.rm_rf(spawn_tool_path)
      File.symlink(File.join(CWD, 'script/spawn'), spawn_tool_path)
    end

    if File.exist?(MIME_TYPES_ORIG_PATH)
      FileUtils.cp(MIME_TYPES_ORIG_PATH, File.join(CWD, 'config'))
    else
      puts "mime.types not found. Install nginx perhaps?"
    end
  end

  def self.compile!(apps_yml_file)
    self.prepare

    if File.exists?(apps_yml_file)
      apps_yml = YAML.load(ERB.new(File.read(apps_yml_file)).result(Object.send(:binding)))
      apps_config = ''
      location_string = ''

      tmp = NGINX_DEFAULTS
      tmp = {
        :listen => apps_yml['nginx']['listen'],
        :port => apps_yml['nginx']['port'].to_s
      }

      # set template
      if apps_yml['nginx']['ssl']
        location_template = NGINX_SSL_LOCATION_TEMPLATE
      else
        location_template = NGINX_HTTP_LOCATION_TEMPLATE
      end

      # apps
      apps_yml['applications'].each do |k, v|
        rstring = NGINX_APP_TEMPLATE.gsub('%app%', k)
        apps_config.concat(rstring.gsub('%port%', "#{v["port"]}"))
      end

      # hosts
      apps_yml['hosts'].each do |k, v|
        v['host'] = [v['host']] unless v['host'].is_a? Array
        v['host'].each do |h|
          # routes

          location_string = ''

          v['routes'].each do |r|
            lstring = location_template.gsub('%route%', r.first)
            lstring = lstring.gsub('%proxy%', r.last)
            location_string.concat(lstring + "\n")
          end

        if apps_yml['nginx']['ssl_rewrite']
          rstring = NGINX_SSL_SERVER_TEMPLATE.gsub('%host%', h)
          rstring = rstring.gsub('%cert_path%', apps_yml['nginx']['cert_path'])
          rstring = rstring.gsub('%key_path%', apps_yml['nginx']['key_path'])
        else
          rstring = NGINX_SERVER_TEMPLATE.gsub('%host%', h)
        end

        rstring = rstring.gsub('%ip%', tmp[:listen])
        rstring = rstring.gsub('%port%', tmp[:port])
        rstring = rstring.gsub('%location%', location_string)

        apps_config.concat(rstring)
        end
        FileUtils.mkdir_p(CONFD_PATH) if !File.exist? CONFD_PATH
        File.open(File.join(CONFD_PATH, 'caresharing.conf'), 'w') { |f| f.write(apps_config) }
      end
    end
  end

  NGINX_APP_TEMPLATE = <<NGAPT
# %app%
upstream %app%_proxy {
  server 127.0.0.1:%port%;
}

NGAPT

  NGINX_SERVER_TEMPLATE = <<NGST
server {
  listen %ip%:%port%;
  server_name %host%;
  access_log logs/%host%-access.log;

%location%
}

NGST

  NGINX_SSL_SERVER_TEMPLATE = <<NGSST
# %host%
server {
  listen %ip%:80;
  server_name %host%;

  location / {
    rewrite ^/(.*)$ https://%host%/$1 permanent;
  }
}

server {
  listen %ip%:443;
  server_name %host%;
  access_log logs/%host%-access.log;
  ssl on;
  ssl_certificate %cert_path%;
  ssl_certificate_key %key_path%;
  ssl_protocols SSLv3 TLSv1;
  ssl_ciphers ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP;

%location%
}
NGSST

  NGINX_SSL_LOCATION_TEMPLATE = <<NGLT
  location %route% {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X_FORWARDED_PROTO https;
    proxy_redirect off;
    proxy_connect_timeout 900;
    proxy_send_timeout 900;
    proxy_read_timeout 900;
    proxy_pass http://%proxy%;
  }
NGLT

  NGINX_HTTP_LOCATION_TEMPLATE = <<NGLT
  location %route% {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_connect_timeout 900;
    proxy_send_timeout 900;
    proxy_read_timeout 900;
    proxy_pass http://%proxy%;
  }
NGLT

  NGINX_DEFAULTS = {
    :listen => '127.0.0.1',
    :port => '8088'
  }

end
