require 'securerandom'

module TestHelpers
  module EventHelpers

    private

    def context
      @context ||= LambdaContext.new
    end

    def invoke_event(deadline_ms_from_now: 2000)
      deadline_ms = (Time.now.to_f * 1000).to_i + deadline_ms_from_now
      {
        "eventType" => "INVOKE",
        "deadlineMs" => deadline_ms,
        "requestId" => context.aws_request_id,
        "invokedFunctionArn" => "arn:aws:lambda:us-east-1:012345678901:function:lambdapunch:live",
        "tracing" => {
            "type" => "X-Amzn-Trace-Id",
            "value" => "Root=1-60d26025-01eef3a30f72afd16dfb2982;Parent=7905e3756d42aff7;Sampled=0"
        }
      }
    end

  end

  class LambdaContext

    def aws_request_id
      @aws_request_id ||= SecureRandom.uuid
    end

    def invoked_function_arn
      'arn:aws:lambda:us-east-1:012345678901:function:lambdapunch:live'
    end

    def log_stream_name
      '2020/07/05[$LATEST]88b3605521bf4d7abfaa7bfa6dcd45f1'
    end

    def function_name
      'lambdapunch'
    end

    def memory_limit_in_mb
      '512'
    end

    def function_version
      '$LATEST'
    end

  end
end
