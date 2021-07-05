require 'test_helper'

class WorkerTest < LambdaPunchSpec

  it 'timeout can be 0 or negative and run instantly' do
    @expected = false
    event = invoke_event deadline_ms_from_now: -1000
    LambdaPunch.push { @expected = true }
    out = capture(:stdout) { LambdaPunch::Worker.call(event) }
    expect(@expected).must_equal true
    expect(out).wont_include 'timeout reached'
  end

  it 'will not timeout when file notifier handles the request early' do
    @expected = false
    event = invoke_event deadline_ms_from_now: 3000
    LambdaPunch.push { @expected = true }
    LambdaPunch.handled!(context)
    out = capture(:stdout) { LambdaPunch::Worker.call(event) }
    expect(@expected).must_equal true
    expect(out).wont_include 'timeout reached'
  end

end
