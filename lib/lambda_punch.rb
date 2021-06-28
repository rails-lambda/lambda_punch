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
require 'lambda_punch/railtie' if defined?(Rails)

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

  extend self

end
