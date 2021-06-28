module LambdaPunch
  # Interface to Lambda's Extensions API using simple `Net::HTTP` calls.
  # 
  #   Lambda Extensions API
  #   https://docs.aws.amazon.com/lambda/latest/dg/runtimes-extensions-api.html
  # 
  class Api

    EXTENSION_NAME = 'lambdapunch'

    include Singleton

    class << self

      def register!
        instance.register!
      end

      def loop
        instance.loop
      end

    end

    def register!
      return if @registered
      uri = URI.parse "#{base_uri}/register"
      http = Net::HTTP.new uri.host, uri.port
      request = Net::HTTP::Post.new uri.request_uri
      request['Content-Type'] = 'application/vnd.aws.lambda.extension+json'
      request['Lambda-Extension-Name'] = EXTENSION_NAME
      request.body = %q|{"events":["INVOKE","SHUTDOWN"]}|
      http.request(request).tap do |r|
        logger.debug "Api#register! => #{r.class.name.inspect}, body: #{r.body}"
        @registered = true
        @extension_id = r.each_header.to_h['lambda-extension-identifier']
        logger.debug "Api::ExtensionId => #{@extension_id}"
      end
    end

    def loop
      resp = event_next
      event_payload = JSON.parse(resp.body)
      case event_payload['eventType']
      when 'INVOKE'   then invoke(event_payload)
      when 'SHUTDOWN' then shutdown
      else
        event_type_error(event_payload)
      end
    end

    private

    def event_next
      uri = URI.parse "#{base_uri}/event/next"
      http = Net::HTTP.new uri.host, uri.port
      request = Net::HTTP::Get.new uri.request_uri
      request['Content-Type'] = 'application/vnd.aws.lambda.extension+json'
      request['Lambda-Extension-Identifier'] = @extension_id
      http.request(request).tap do |r|
        logger.debug "Api#event_next => #{r.class.name.inspect}, body: #{r.body}"
      end
    end

    def invoke(event_payload)
      logger.debug "Api#invoke => #{JSON.dump(event_payload)}" if logger.debug?
      Worker.call(event_payload)
    end

    def shutdown
      logger.info 'Api#shutdown...'
      DRb.stop_service rescue true
      exit
    end

    private

    def base_uri
      "http://#{ENV['AWS_LAMBDA_RUNTIME_API']}/2020-01-01/extension"
    end

    def logger
      LambdaPunch.logger
    end

    def event_type_error(event_payload)
      message = "Unknown event type: #{event_payload['eventType'].inspect}"
      logger.fatal(message)
      raise EventTypeError.new(message)
    end

  end
end
