use Rack::ShowExceptions
use Rack::CommonLogger

run lambda { |env| [200, {'Content-Type' => 'text/html'}, ["Hello from your rack app!\n"]] }