module BackgroundProxy
  class Proxy

    def initialize(client, options = {})
      @client = client
      @options = options
    end

    private

    attr_reader :client, :options

    def worker
      @worker ||= begin
        Worker.new(client, options)
      end
    end

    def method_missing(method, *args)
      if client.respond_to?(method)
        worker.async(method, *args)
      else
        super
      end
    end

    def respond_to_missing?(method)
      client.respond_to?(method) || super
    end

  end
end