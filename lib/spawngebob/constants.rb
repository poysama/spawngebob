module Spawngebob
  module Constants
    BASE_CONFIG_PATH = File.join(ENV['HOME'], '.spawngebob')
    NGINX_PATH = File.join(BASE_CONFIG_PATH, 'nginx')
    NGINX_CONF_PATH = File.join(NGINX_PATH, 'conf')
    NGINX_CONFD_PATH = File.join(NGINX_PATH, 'conf.d')
    NGINX_CONF = 'nginx.conf'
    NGINX_PID = 'nginx.pid'
    NGINX_DIRS = ['tmp', 'run', 'logs', 'conf.d', 'conf']
    CONFIG_FILE = 'apps.yml'
    SCRIPT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../../script/nginx'))

    NGINX_DEFAULTS = {
      'listen' => '127.0.0.1',
      'port' => '8088'
    }

    NGINX_UPSTREAM_TEMPLATE = <<NUT
# %app%
upstream %app%_proxy {
  server 127.0.0.1:%port%;
}
NUT

    NGINX_SERVER_TEMPLATE = <<NST
server {
  listen %ip%:%port%;
  server_name %host%;
  access_log logs/%host%-access.log;

%location%
}
NST

    NGINX_SSL_SERVER_TEMPLATE = <<NSSL
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
  include /usr/local/nginx/conf.d/denied_locations.inc;
}
NSSL

    NGINX_SSL_LOCATION_TEMPLATE = <<NSLT
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
NSLT

    NGINX_HTTP_LOCATION_TEMPLATE = <<NHLT
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
NHLT
  end
end
