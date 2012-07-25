use Rack::ShowExceptions
use Rack::CommonLogger

redis_yml = File.expand_path("../config/redis.yml", __FILE__)
if File.exist?(redis_yml)
  require "yaml"
  redis_conf = YAML.load_file(redis_yml)
  run lambda { |env| [200, {'Content-Type' => 'text/html'}, ["Hello from your rack app with redis!\n#{redis_conf.inspect}\n"]] }
else
  run lambda { |env| [200, {'Content-Type' => 'text/html'}, ["Hello from your rack app!\n"]] }
end