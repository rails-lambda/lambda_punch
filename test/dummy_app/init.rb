require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'rails/test_unit/railtie'

module Dummy
  class Application < ::Rails::Application
    config.root = File.join __FILE__, '..'
    config.eager_load = true
    logger = ActiveSupport::Logger.new(StringIO.new)
    logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    config.logger = logger
    config.active_job.queue_adapter = :lambda_punch
  end
end

Dummy::Application.initialize!
