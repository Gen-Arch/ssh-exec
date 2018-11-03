require 'net/ssh'

module SSH::Exec
  class Session
    attr_accessor :shell
    attr_accessor :result
    attr_accessor :streams
    attr_accessor :session

    def initialize(host, id, **opt, &block)
      @token = "XXXDONEXXX"
      @pattan = /^XXXDONEXXX (\d+)$/
      @result = Array.new
      @session = Net::SSH.start(host, id, opt)
    end

    def start!(**opt, &block)
      @shell = opt[:shell] || "bash -l"
      @block = block
      open

      return result
    end

    def stdin(cmd, **opt)
      @streams = {:stdin => cmd}
      @channel.send_data("#{streams[:stdin]}\necho '#{@token}'")
      Fiber.yield

      return streams
    end

    def open
      channel = session.open_channel(&method(:open_succeeded))
      channel.wait
    end

    def open_succeeded(channel)
      channel.exec(shell?, &method(:cmd_exec))
    end

    def cmd_exec(channel, success)
      raise "sesstion error!!" unless success
      channel.send_data "export TERM=vt100\necho '#{@token}' $?\n"
      @channel = channel
      f =  Fiber.new do
        @block.call self
        channel.send_data("exit\n")
      end

      channel.on_data do |c,data|
        if data =~ @pattan
          rc = $1.to_i
          streams.merge!(:rc => rc) 
          res = streams
          result << streams
          streams = Hash.new
          f.resume res
        else
          streams.merge!(:stdout => data)
        end
        channel.on_extended_data{|c,type,data| streams.merge!(:stderr => data)}
      end
    end

    def shell?
      return streams[:stdin] if shell.nil?
      return shell
    end

  end
end
