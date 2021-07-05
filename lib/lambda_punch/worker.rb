module LambdaPunch
  # This `LambdaPunch::Worker` has a few responsibilities:
  # 
  #   1. Maintain a class level DRb reference to your function's `LambdaPunch::Queue` object.
  #   2. Process extension `INVOKE` events by waiting for your function to complete.
  #   3. Triggering your application to perform work after each request.
  # 
  class Worker

    class << self
      
      # Method to lazily require rb-inotify and start the DRb service.
      # 
      def start!
        LambdaPunch.logger.info "Worker.start!..."
        require 'timeout'
        require 'rb-inotify'
        DRb.start_service
        new_drb_queue
      end

      # Creates a new instance of this object with the event payload from the `LambdaPunch::Api#invoke` 
      # method and immediately performs the `call` method which waits for the function's handler to complete.
      #
      def call(event_payload)
        new(event_payload).call
      end

      # A safe and resilient way to call the remote queue.
      # 
      def call_queue
        queue.call
      rescue DRb::DRbConnError
        LambdaPunch.logger.error "Worker#call_queue => DRb::DRbConnError"
        new_drb_queue
        queue.call
      end

      private

      # The `@queue` object is the local process' reference to the application `LambdaPunch::Queue`
      # instance which does all the work in the applciation's scope.
      # 
      def queue
        @queue
      end

      def new_drb_queue
        @queue = DRbObject.new_with_uri(Server.uri)
      end

    end

    def initialize(event_payload)
      @invoked = false
      @event_payload = event_payload
      @notifier = Notifier.new
      @notifier.watch { |request_id| notified(request_id) }
      @request_id_notifier = nil
    end

    # Here we wait for the application's handler to signal it is done via the `LambdaPunch::Notifier` or if the 
    # function has timed out. In either event there may be work to perform in the `LambdaPunch::Queue`. This method
    # also ensures any clean up is done. For example, closing file notifications.
    #
    def call
      timeout { @notifier.process unless invoked? }
    rescue Timeout::Error
      logger.error "Worker#call => Function timeout reached."
    ensure
      @notifier.close
      self.class.call_queue
    end

    private

    # The Notifier's watch handler would set this instance variable to `true`. We also return `true`
    # if the extension's invoke palyload event has a `requestId` matching what the handler has written
    # to the `LambdaPunch::Notifier` file location. See also `request_ids_match?` method. Lastly if 
    # the timeout 
    #
    def invoked?
      @invoked || request_ids_match? || timed_out?
    end

    # The unique AWS reqeust id that both the extension and handler receive for each invoke. This one
    # represents the extension's side.
    # 
    def request_id_payload
      @event_payload['requestId']
    end

    # Set via the `LambdaPunch::Notifier` watch event from the your function's handler.
    # 
    def request_id_notifier
      @request_id_notifier
    end

    # Check if notified via inotify or in some rare case the function's handler has already completed 
    # and written the matching request id via the context object to the `LambdaPunch::Notifier` file.
    #
    def request_ids_match?
      request_id_payload == (request_id_notifier || Notifier.request_id)
    end

    # A safe timeout method which accounts for a 0 or negative timeout value.
    # 
    def timeout
      @timeout = timeout_seconds
      if timed_out?
        yield
      else
        Timeout.timeout(@timeout) { yield }
      end
    end

    # Helps guard for deadline milliseconds in the past.
    # 
    def timed_out?
      @timeout == 0 || @timeout < 0
    end

    # The function's timeout in seconds using the `INVOKE` event payload's `deadlineMs` value.
    # 
    def timeout_seconds
      deadline_milliseconds = @event_payload['deadlineMs']
      deadline = Time.at(deadline_milliseconds / 1000.0)
      deadline - Time.now
    end

    # Our `LambdaPunch::Notifier` instance callback.
    # 
    def notified(request_id)
      @invoked = true
      @request_id_notifier = request_id
    end

    def logger
      LambdaPunch.logger
    end

    def noop ; end

  end
end
