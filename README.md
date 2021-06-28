![LambdaPunch](https://user-images.githubusercontent.com/2381/123561512-c23fb580-d776-11eb-9780-71d606cd8f2c.png)

![Test](https://github.com/customink/lambda_punch/workflows/Test/badge.svg)

# 👊 LambdaPunch

<a href="https://lamby.custominktech.com"><img src="https://user-images.githubusercontent.com/2381/59363668-89edeb80-8d03-11e9-9985-2ce14361b7e3.png" alt="Lamby: Simple Rails & AWS Lambda Integration using Rack." align="right" width="300" /></a>Asynchronous background job processing for AWS Lambda with Ruby using [Lambda Extensions](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-extensions-api.html). Inspired by the [SuckerPunch](https://github.com/brandonhilkert/sucker_punch) gem but specifically tooled to work with Lambda's invoke model.

**For a more robust background job solution, please consider using AWS SQS with the [Lambdakiq](https://github.com/customink/lambdakiq) gem. A drop-in replacement for [Sidekiq](https://github.com/mperham/sidekiq) when running Rails in AWS Lambda using the [Lamby](https://lamby.custominktech.com/) gem.**

## 🏗 Architecture

Because AWS Lambda [freezes the execution environment](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-context.html) after each invoke, there is no "process" that continues to run after the handler's response. However, thanks to Lambda Extensions along with its "early return", we can do two important things. First, we leverage the [rb-inotify](https://github.com/guard/rb-inotify) gem to send the extension process a simulated `POST-INVOKE` event. We then use [Distributed Ruby](https://ruby-doc.org/stdlib-3.0.1/libdoc/drb/rdoc/DRb.html) (DRb) from the extension to signal your application to work jobs off a queue. Both of these are synchronous calls. Once complete the LambdaPunch extensions signals it is done and your function is ready for the next request.

<img src="https://user-images.githubusercontent.com/2381/123647632-408f6c80-d7f6-11eb-8e39-fb4ee92b1ffa.png" width="100%" alt="AWS Lambda Extensions with LambdaPunch async job queue processing." >

The LambdaPunch extension process is very small and lean. It only requires a few Ruby libraries and needed gems from your application's bundle. Its only job is to send signals back to your application on the runtime. It does this within a few milliseconds and adds no noticeable overhead to your function.

## 🎁 Installation

Add this line to your project's `Gemfile` and then make sure to `bundle install` afterward.

```ruby
gem 'lambda_punch'
```

Now, within your application's handler file, make sure to start the LambdaPunch DRb server outside of your handler method. Within the handler method, add an `ensure` section that lets the extension process know the request is done.

```ruby
LambdaPunch.start_server!

def handler(event:, context:)
  # ...
ensure
  LambdaPunch.handled!(context)
end
```

Within your project or [Rails application's](https://lamby.custominktech.com/docs/anatomy) `Dockerfile`, after you copy your code, add this `RUN` command to install the extension within your container's `/opt/extensions` directory.

```dockerfile
RUN bundle exec rake lambda_punch:install
```

## 🧰 Usage

Anywhere in your application's code, use the `LambdaPunch.push` method to add blocks of code to your jobs queue.

```ruby
LambdaPunch.push do
  # ...
end
```

For example, if you are using Rails with AWS Lambda via the [Lamby](https://lamby.custominktech.com/) gem along with [New Relic APM](https://dev.to/aws-heroes/using-new-relic-apm-with-rails-on-aws-lambda-51gi) here is how your handler function might appear to ensure their metrics are flushed after each request.

```ruby
def handler(event:, context:)
  Lamby.handler $app, event, context
ensure
  LambdaPunch.push { NewRelic::Agent.agent.flush_pipe_data }
  LambdaPunch.handled!(context)
end
```

### ActiveJob

🚧 COMING SOON 🚧 - A simple ActiveJob adapter...

### Timeouts

Your function's timeout is the max amount to handle the request and process all extension's invoke events. If your function times out, it is possible that queued jobs will not be processed until the next invoke.

If your application integrates with API Gateway (which has a 30 second timeout) then it is possible your function can be set with a higher timeout to perform background work. Since work is done after each invoke, the LambdaPunch queue should be empty when your function receives the `SHUTDOWN` event. If jobs are in the queue when this happens they will have two seconds max to work them down before being lost.

**For a more robust background job solution, please consider using AWS SQS with the [Lambdakiq](https://github.com/customink/lambdakiq) gem. A drop-in replacement for [Sidekiq](https://github.com/mperham/sidekiq) when running Rails in AWS Lambda using the [Lamby](https://lamby.custominktech.com/) gem.**

### Logging

The default log level is `fatal`, so you will not see any LambdaPunch lines in your logs. However, if you want some low level debugging information on how LambdaPunch is working, you can use this environment variable to change the log level.

```yaml
Environment:
  Variables:
    LAMBDA_PUNCH_LOG_LEVEL: debug
```

## 📊 CloudWatch Metrics

When using Extensions, your function's CloudWatch `Duration` metrics will be the sum of your response time combined with your extension's execution time. For example, if your request takes `200ms` to respond but your background task takes `1000ms` your duration will be a combined `1200ms`. For more details see the _"Performance impact and extension overhead"_ section of the [Lambda Extensions API
](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-extensions-api.html)

Thankfully, when using Lambda Extensions, CloudWatch will create a `PostRuntimeExtensionsDuration` metric that you can use to isolate your true response times `Duration` [using some metric math](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/using-metric-math.html). Here is an example where the metric math above is used in the first "Duration (response)" widget.

![metric-math](https://user-images.githubusercontent.com/2381/123561591-4eea7380-d777-11eb-8682-c20b9460f112.png)

![durations](https://user-images.githubusercontent.com/2381/123561590-4e51dd00-d777-11eb-96b2-d886c91aedb0.png)

## 👷🏽‍♀️ Development

After checking out the repo, run the following commands to build a Docker image and install dependencies.

```shell
$ ./bin/bootstrap
$ ./bin/setup
```

Then, to run the tests use the following command.

```shell
$ ./bin/test
```

You can also run the `./bin/console` command for an interactive prompt within the development Docker container. Likewise you can use `./bin/run ...` followed by any command which would be executed within the same container.

## 💖 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/customink/lambda_punch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/customink/lambda_punch/blob/main/CODE_OF_CONDUCT.md).

## 👩‍⚖️ License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🤝 Code of Conduct

Everyone interacting in the LambdaPunch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/customink/lambda_punch/blob/main/CODE_OF_CONDUCT.md).
