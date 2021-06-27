## Documentation

- A function with an extensions has a shutdown timeout of 2s.
- 2,000 ms – A function with one or more registered external extensions

#### CloudWatch Metrics

When using Extensions, your function's CloudWatch `Duration` metrics will be the sum of your response time combined with your extension's execution time. For example, if your request takes `200ms` to respond but your need to process a background task which takes `1000ms` your duration will be `1200ms` total. For more details see the "Performance impact and extension overhead" section of the [Lambda Extensions API
](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-extensions-api.html)

Thankfully, when using Lambda Extensions, CloudWatch will create a `PostRuntimeExtensionsDuration` metric that you can use to isolate your true response times `Duration` [using some metric math](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/using-metric-math.html). Here is an example

#### Logging

Default :fatal.

```yaml
Environment:
  Variables:
    LAMBDA_PUNCH_LOG_LEVEL: debug
```

## Development

```ruby

# Queuing Works
class Queue
  JOBS = []
  def self.push(block)
    JOBS << block
  end
end
module LambdaPunch
  def push(&block)
    Queue.push(block)
  end
  extend self
end
LambdaPunch.push do
  sleep(1)
end

# Seconds to Milliseconds
(1000.0 * 0.1).to_i   # => 100
(1000.0 * 0.01).to_i  # => 10

# Milliseconds to Seconds
100 / 1000.0          # => 0.1
10 / 1000.0           # => 0.01

>> Timeout.timeout(0.01) { sleep(0.009) }
>> Timeout.timeout(0.01) { sleep(0.011) }
Timeout::Error (execution expired)


# Do concurrent ruby timeouts do anything when not needed? No!
require 'concurrent'
require 'concurrent/edge/cancellation'
t = Concurrent::Cancellation.timeout(10)
Concurrent.global_io_executor.post(t) do |timeout|
  puts 'here'
end


# Final working solution I like.
require 'rb-inotify'
require 'concurrent'
require 'concurrent/edge/cancellation'
@file = "./lambdapunch-handled"
File.open(@file, 'w') { |f| f.write('') }
def noop ; true ; end
def noopn(n) ; sleep(n) ; end
@request_id = nil
@notifier = INotify::Notifier.new
@notifier.watch(@file, :modify, :oneshot) { File.read(@file) }
def p1
  @c1, @o1 = Concurrent::Cancellation.new
  @p1 = Concurrent::Promises.future do
    @notifier.process
    puts 'notified'
    File.read(@file)
  end
end
def p2
  @c2 = Concurrent::Cancellation.timeout(60)
  @p2 = Concurrent::Promises.future do
    noop until @c1.canceled? || @c2.canceled?
    if @c2.canceled?
      puts 'timeout'
      @c1.origin.resolve
      :timeout
    else
      puts 'notifier_resolved'
      :notifier_resolved
    end
  end
end
@p3 = Concurrent::Promises.any_resolved_future(p2, p1)
File.open(@file,'w') { |f| f.write('123') }
@p3.wait.value
@notifier.close





p1 = Concurrent::Promises.future do
  do_stuff until c.canceled?

end
# => #

c.origin.resolve
# => #
async_task.value!








@i = 1
def do_stuff ; @i += 1 ; end
c, o = Concurrent::Cancellation.new
Concurrent::Promises.future(c) do |c|
  # Do work repeatedly until it is cancelled
  do_stuff until c.canceled?
  :stopped_gracefully
end
o.resolve

require 'concurrent'
require 'concurrent/edge/cancellation'
@i = 1
def do_stuff ; @i += 1 ; end
# t = Concurrent::Cancellation.new Concurrent::Promises.schedule(0.02)
t = Concurrent::Cancellation.timeout 59.99802703818213
p = Concurrent.global_io_executor.post(t) do |t|
  do_stuff until t.canceled?
  puts('here')
  :done
end
t.origin.resolve
t.origin.resolved?
t.origin.wait
puts 'here'

c, o = Concurrent::Cancellation.new
p = Concurrent::Promises.future(c) do |c|
  true until c.canceled?
end




p1 = Concurrent::Promises.future(3) do |n|
  sleep(n)
  puts "notifier#{n}"
  n
end
p2 = Concurrent::Promises.future(5) do |n|
  sleep(n)
  puts "notifier#{n}"
  n
end
Concurrent::Promises.any_resolved_future(p1,p2).wait.value




require 'concurrent'
require 'concurrent/edge/cancellation'
@i = 1
def do_stuff ; @i += 1 ; end
p1 = Concurrent::Promises.future(3) do |n|
  sleep(n)
  puts "notifier#{n}"
  n
end
p2 = Concurrent::Promises.future(5) do |n|
  sleep(n)
  puts "notifier#{n}"
  n
end
Concurrent::Promises.any_resolved_future(p1,p2).wait.value

c = Concurrent::Cancellation.timeout(12.882)
p2 = Concurrent::Promises.future(c) do |c|
  do_stuff until c.canceled?
  puts 'timeout'
  :request_id_payload
end
Concurrent::Promises.any_resolved_future(p1,p2).wait


@i = 1
@rid = 'aaa-bbb-ccc'
def do_stuff ; @i += 1 ; if @i == 588928 ; @invoked = true ; end ; end
t = Concurrent::Cancellation.timeout 5
p = Concurrent::Promises.future do
  do_stuff until @invoked || t.canceled?
  @rid
end
p.wait

@invoked = false

!t.canceled?

p = Concurrent::Promises.future(t) { |t| }
while
  puts 't'
end
t.cancel
puts 'here'

p.set('test')

p.fulfill('test')
t.origin.wait


t.origin.wait
puts 'here'






Time.at(1624399969622/1000.0)
=> 2021-06-22 18:12:49 2608857/4194304 -0400

(Time.at(1624399969622/1000.0).to_f * 1000.0).to_i
=> 1624399969622

>> Time.at(1624399969622/1000.0) < Time.at(1624399969623/1000.0)
=> true
>> Time.at(1624399969622/1000.0) < Time.at(1624399969621/1000.0)
=> false
```

## Benchmarks

ab -n 100 -c 1 ...

Time taken for tests: 12.814 seconds

50% 124
66% 127
75% 128
80% 129
90% 143
95% 175
98% 202
99% 212
100% 212 (longest request)

Time taken for tests: 12.998 seconds

50% 125
66% 130
75% 133
80% 135
90% 146
95% 176
98% 200
99% 206
100% 206 (longest request)
