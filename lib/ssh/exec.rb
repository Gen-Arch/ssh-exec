$: << __dir__

module SSH
  module Exec
  require "exec/session"
  end
end

if __FILE__ == $0
  session = SSH::Exec::Session.new("192.168.0.104", "gen", :keys => "#{ENV['HOME']}/.ssh/gen-server")
  res = session.stdin(["ls -al", "hostname", "echo aaaa"], :shell => "bash -l")
  pp res
end
