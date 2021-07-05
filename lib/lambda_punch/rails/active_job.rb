module ActiveJob
  module QueueAdapters
    class LambdaPunchAdapter

      def enqueue(job, options = {})
        job_data = job.serialize
        LambdaPunch.push { ActiveJob::Base.execute(job_data) }
      end

      def enqueue_at(job, timestamp)
        enqueue(job)
      end

    end
  end
end
