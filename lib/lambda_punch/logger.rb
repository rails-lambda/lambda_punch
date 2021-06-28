module LambdaPunch
  class Logger

    def logger
      @logger ||= ::Logger.new(STDOUT).tap do |l| 
        l.level = level
        l.formatter = proc { |_s, _d, _p, m| "[LambdaPunch] #{m}\n" }
      end
    end

    def level=(value)
      @level = value.to_s
      @logger = nil
    end

    private

    def level
      l = (@level || ENV['LAMBDA_PUNCH_LOG_LEVEL'] || 'fatal').upcase.to_sym
      ::Logger.const_defined?(l) ? ::Logger.const_get(l) : ::Logger::FATAL
    end

  end
end
