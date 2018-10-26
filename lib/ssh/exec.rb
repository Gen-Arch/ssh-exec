$: << __dir__


module SSH
  module Exec
  require "exec/session"
  end
end

if __FILE__ == $0
  session = SSH::Exec::Session.new
  out, err = session.exec("ls -al")
  puts out
end
