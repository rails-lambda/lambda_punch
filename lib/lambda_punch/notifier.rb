module LambdaPunch
  class Notifier

    FILE = "#{Dir.tmpdir}/lambdapunch-handled"

    class << self

      def handled!(context)
        File.open(FILE, 'w') do |f|
          f.write context.aws_request_id
        end
      end

      def request_id
        File.read(FILE)
      end

      def tmp_file
        FILE
      end

    end

    def initialize
      @notifier = INotify::Notifier.new
      File.open(FILE, 'w') { |f| f.write('') } unless File.exist?(FILE)
    end

    def watch
      @notifier.watch(FILE, :modify, :oneshot) { yield(request_id) }
    end

    def process
      @notifier.process
    end

    def close
      logger.debug "Notifier#close"
      @notifier.close rescue true
    end

    def request_id
      self.class.request_id
    end

    private

    def logger
      LambdaPunch.logger
    end

  end
end
