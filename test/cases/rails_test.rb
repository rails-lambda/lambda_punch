require 'test_helper'

class RailsTest < LambdaPunchSpec

  it 'works with active job' do
    expect(lambda_punch_jobs.length).must_equal 0
    BasicJob.perform_later(42)
    expect(lambda_punch_jobs.length).must_equal 1
    LambdaPunch::Queue.new.call
    expect(perform_buffer_last_value).must_equal "BasicJob with: 42"
  end

end
