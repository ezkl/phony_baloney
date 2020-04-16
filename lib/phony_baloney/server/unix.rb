require 'socket'

module PhonyBaloney
  module Server
    class UNIX

      def initialize(path:)
        @path = path
        @buf = Buffer.new
        @stopping = false
      end

      def run
        @socket = UNIXServer.new(@path)
        @t = Thread.new(&method(:handler))

        begin yield @buf
        ensure
          stop
        end if block_given?
      end

      def handler
        Thread.current.report_on_exception = true
        client = @socket.accept
        begin
          loop do
            return if @stopping

            rc = client.recv(16384)

            @buf << rc
          end

        rescue IO::WaitReadable
          IO.select([@socket])
          retry
        rescue Errno::EBADF
          raise if !@stopping
        rescue IOError
          raise if !@stopping
        ensure
          client.close
        end
      end
      private :handler

      def stop
        @stopping = true
        @socket.close
        @buf.close
        true
      end

    end
  end
end
