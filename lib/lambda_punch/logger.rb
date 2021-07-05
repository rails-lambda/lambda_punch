module LambdaPunch
  class Logger

    attr_reader :level

    def initialize
      @level = (ENV['LAMBDA_PUNCH_LOG_LEVEL'] || 'error').upcase.to_sym
    end

    def logger
      @logger ||= ::Logger.new(STDOUT).tap do |l| 
        l.level = logger_level
        l.formatter = proc { |_s, _d, _p, m| "[LambdaPunch] #{m}\n" }
      end
    end

    private

    def logger_level
      ::Logger.const_defined?(@level) ? ::Logger.const_get(@level) : ::Logger::ERROR
    end

  end
end
