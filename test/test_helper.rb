ENV['RAILS_ENV'] = 'test'
require 'rails'
require 'lambda_punch'
require 'pry'
require 'minitest/autorun'
require 'minitest/focus'
require_relative './dummy_app/init'
require_relative './test_helpers/stream_helpers'
require_relative './test_helpers/event_helpers'
require_relative './test_helpers/jobs_helpers'

LambdaPunch.start_server!
LambdaPunch.start_worker!

class LambdaPunchSpec < Minitest::Spec

  include TestHelpers::StreamHelpers,
          TestHelpers::EventHelpers,
          TestHelpers::JobsHelpers

  before do
    clear_lambda_punch_queue!
    perform_buffer_clear!
  end

end
