import config from require "lapis.config"

config {"production", "development"}, ->
  secret "yolosecret2014"
  postgresql_url "postgres://bash:86Fotballpersonlegdom@172.17.42.1/lapiswiki"

config "production", ->
  port 8080
  code_cache "on"
