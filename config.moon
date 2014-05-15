import config from require "lapis.config"

config {"production", "development"}, ->
  session_name "bash"
  secret "yolosecret2014"
  postgresql_url "postgres://bash:86Fotballpersonlegdom@172.17.42.1/bash"

config "production", ->
  port 8080
  code_cache "on"
