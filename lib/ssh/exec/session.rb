require 'net/ssh'

module SSH::Exec
  class Session
    attr_accessor :host
    attr_accessor :id
    attr_accessor :shell
    attr_accessor :result
    attr_accessor :streams
    attr_accessor :session

    def initialize(host, id, **opt)
      @host = host
      @id = id
      @option = opt
      @result = Array.new
      @session = Net::SSH.start(@host, @id, @option)
    end

    def stdin(cmd, **opt)
      @shell = (opt[:shell] || nil)
      @streams = {:stdin => cmd}
      open

      result << streams
      return streams
    end

    def open
      channel = session.open_channel(&method(:open_succeeded))
      channel.wait
    end

    def open_succeeded(channel)
      channel.exec(shell?, &method(:cmd_exec))
      channel.on_close
    end

    def cmd_exec(channel, success)
      raise "sesstion error!!" unless success
      unless shell.nil?
        streams[:stdin].each{|cmd| channel.send_data "#{cmd}\n"} if streams[:stdin].is_a?(Array)
        channel.send_data "#{streams[:stdin]}\n" if streams[:stdin].is_a?(String)
        channel.send_data "exit\n"
      end
      channel.on_data{|c,data| streams.merge!(:stdout => data)}
      channel.on_extended_data{|c,type,data| streams.merge!(:stderr => data)}
    end

    def shell?
      return streams[:stdin] if shell.nil?
      return shell
    end

  end
end

