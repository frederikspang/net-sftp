require 'net/ssh/loggable'
require 'net/sftp/operations/file'

module Net; module SFTP; module Operations

  class FileFactory
    attr_reader :sftp

    def initialize(sftp)
      @sftp = sftp
    end

    def open(name, flags="r", mode=nil, &block)
      request = sftp.open(name, flags, :permissions => mode, &method(:do_open))
      file = Operations::File.new(sftp)
      request[:file] = file
      request.wait

      if block_given?
        begin
          yield file
        ensure
          file.close
        end
      else
        return file
      end
    end

    private

      def do_open(response)
        file = response.request[:file]
        raise "open failed: #{response}" unless response.ok?
        file.establish!(response[:handle])
      end
  end

end; end; end