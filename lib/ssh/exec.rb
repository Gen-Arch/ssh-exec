$: << __dir__

module SSH
  module Exec
  require "exec/session"
  end
end

if __FILE__ == $0
  session = SSH::Exec::Session.new("192.168.0.104", "gen", :keys => "#{ENV['HOME']}/.ssh/gen-server")
  session.start! do |s|
    res = s.stdin "ls"
    pp res
  end
end
