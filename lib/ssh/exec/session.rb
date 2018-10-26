require 'net/ssh'

module SSH::Exec
  class Session
    attr_accessor :session

    def initialize
      @host = '192.168.0.104'
      @name = 'gen'
      @option = {:keys => ["#{ENV['HOME']}/.ssh/gen-server"]}
      @session = Net::SSH.start(@host, @name, @option)
    end

    def exec(command)
      stdout = String.new
      stderr = String.new
      channel = @session.open_channel do |ch|
        ch.exec(command) do |ch, success|
          raise "sesstion error!!" unless success
          ch.on_data do |c,data|
            stdout =  data
          end

          ch.on_extended_data do |c,type,data|
            stderr data
          end
        end
        ch.on_close
      end
      channel.wait
      return stdout, stderr
    end

  end
end

if __FILE__ == $0
  session = SSH::Exec::Session.new
  out, err = session.exec("ls -al")
  puts out
end
