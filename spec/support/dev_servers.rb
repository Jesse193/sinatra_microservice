RSpec.configure do |config|
  config.before(:suite) do
    $sinatra_pid = spawn("bundle exec rackup -p 9292", chdir: ".")
    $vite_pid    = spawn("npm run dev -- --port 5173", chdir: "../food_haven_react_fe")
    wait_for_port(9292)
    wait_for_port(5173)
  end

  config.after(:suite) do
    Process.kill("TERM", $sinatra_pid)
    Process.kill("TERM", $vite_pid)
  end
end

def wait_for_port(port, timeout: 15)
  Timeout.timeout(timeout) do
    loop do
      TCPSocket.new("localhost", port).close
      break
    rescue Errno::ECONNREFUSED
      sleep 0.2
    end
  end
end