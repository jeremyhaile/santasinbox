require './santasinbox'

enable :logging, :dump_errors, :raise_errors
$stdout.sync = true

run Sinatra::Application
