require 'test_helper'

class QueueTest < LambdaPunchSpec

  before do
    LambdaPunch.error_handler = nil
  end

  it 'must push jobs via blocks to the queue' do
    expect(lambda_punch_jobs.length).must_equal 0
    LambdaPunch.push { }
    expect(lambda_punch_jobs.length).must_equal 1
  end

  it 'must call all jobs and clear queue' do
    @expected = false
    LambdaPunch.push { @expected = true }
    LambdaPunch::Queue.new.call
    expect(lambda_punch_jobs.length).must_equal 0
    expect(@expected).must_equal true
  end

  it 'must be able to call the queue with an invoke event payload using a timeout' do
    @expected = false
    event = invoke_event deadline_ms_from_now: 1000
    LambdaPunch.push { @expected = true }
    out = capture(:stdout) { LambdaPunch::Worker.call(event) }
    expect(@expected).must_equal true
    expect(lambda_punch_jobs.length).must_equal 0
    expect(out).must_include 'timeout reached'
  end

  it 'will log errors' do
    LambdaPunch.push { raise('hell') }
    out = capture(:stdout) { LambdaPunch::Queue.new.call }
    expect(out).must_include 'hell'
  end

  it 'will allow a custom error handler to be used' do
    LambdaPunch.error_handler = lambda { |e| puts("test-#{e.class.name}") }
    LambdaPunch.push { raise('hell') }
    out = capture(:stdout) { LambdaPunch::Queue.new.call }
    expect(out).must_include 'test-RuntimeError'
  end

end
