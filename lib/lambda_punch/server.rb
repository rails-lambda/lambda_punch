module LambdaPunch
  class Server

    include Singleton

    class << self

      def uri
        'druby://127.0.0.1:9030'
      end

      def start!
        require 'concurrent'
        LambdaPunch.logger.info "Server.start!..."
        instance
      end

    end

    def initialize
      @queue = Queue.new
      DRb.start_service self.class.uri, @queue
    end

  end
end
