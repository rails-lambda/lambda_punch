require 'uri'
require 'drb'
require 'json'
require 'tmpdir'
require 'logger'
require 'net/http'
require 'singleton'
require 'lambda_punch/api'
require 'lambda_punch/error'
require 'lambda_punch/logger'
require 'lambda_punch/queue'
require 'lambda_punch/server'
require 'lambda_punch/worker'
require 'lambda_punch/version'
require 'lambda_punch/notifier'
if defined?(Rails)
  require 'lambda_punch/railtie'
  require 'lambda_punch/rails/active_job'
end

module LambdaPunch
  
  def push(&block)
    Queue.push(block)
  end

  def register!
    Api.register!
  end

  def loop
    Api.loop
  end

  def start_server!
    Server.start!
  end

  def start_worker!
    Worker.start!
  end

  def logger
    @logger ||= Logger.new.logger
  end

  def handled!(context)
    Notifier.handled!(context)
  end

  def error_handler
    @error_handler ||= lambda do |e| 
      logger.error "Queue#call::error => #{e.message}"
      logger.error e.backtrace[0..10].join("\n")
    end
  end

  def error_handler=(func)
    @error_handler = func
  end

  def tmp_file
    Notifier.tmp_file
  end

  extend self

end
