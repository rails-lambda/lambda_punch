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
          LambdaPunch.error_handler.call(e)
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

  end
end
