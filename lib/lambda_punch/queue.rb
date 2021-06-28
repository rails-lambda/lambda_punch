module LambdaPunch
  class Queue

    class << self

      def push(block)
        jobs << block
      end

      def jobs
        @jobs ||= Concurrent::Array.new
      end

    end

    def call
      jobs.each do |job| 
        begin
          job.call
        rescue => e
          logger.error "Queue#call::error => #{e.message}"
          # ...
        end
      end
      true
    ensure
      jobs.clear
    end

    private

    def jobs
      self.class.jobs
    end

    def logger
      LambdaPunch.logger
    end
    
  end
end
