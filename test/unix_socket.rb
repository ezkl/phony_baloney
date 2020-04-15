require_relative "helper"

class TestUNIXServer < Minitest::Test

  def test_unix_server
    x = PhonyBaloney::Server::UNIX.new(path: '/tmp/phony_test.sock')

    x.run do |buf|
      large = "bbbbbbbbbbbbbbbbbbbbbbbb" * 1024
      large += "\n"

      cl = UNIXSocket.new('/tmp/phony_test.sock')
      cl << "aaa\n"
      cl << large
      cl << "ccccc"

      assert_equal "aaa\n", buf.gets
      assert_equal large, buf.gets
      assert_equal "ccccc", buf.read(6)

      cl.close
    end
  ensure
    File.unlink('/tmp/phony_test.sock')
  end
end
