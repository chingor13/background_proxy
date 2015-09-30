module BackgroundProxy
  class Worker
    SLEEP_INTERVAL = 5

    def initialize(client, options = {})
      @queue = Queue.new
      @client = client
      @logger = options[:logger]
      spawn_threads!(options.fetch(:threads, 3))

      at_exit do
        check_background_queue until @queue.empty?
      end
    end

    def current_threads
      Thread.list.select {|t| t[:background_logger] == self.object_id}
    end

    def current_thread_count
      Thread.list.count {|t| t[:background_logger] == self.object_id}
    end

    def stopped?
      !!@stopped
    end

    def stop!
      @stopped = true
    end

    def async(method, *args)
      log :debug, "async run: #{method}, #{args}"
      @queue.push({
        method: method,
        args: args
      })
    end

    def spawn_threads!(num_threads)
      num_threads.times do |thread_num|
        log :debug, "Spawning background worker thread #{thread_num}."

        Thread.new do
          Thread.current[:background_logger] = self.object_id

          while !stopped?
            self.check_background_queue(thread_num)
            sleep rand(SLEEP_INTERVAL)
          end
        end
      end
    end

    def check_background_queue(thread_num = 0)
      log :debug, "Checking background queue on thread #{thread_num} (#{self.current_thread_count} active)"

      while !@queue.empty?
        p = @queue.pop(true) rescue next;
        @client.send(p[:method], *p[:args])
      end

    end

    def log(level, msg)
      return unless @logger
      @logger.log(level, msg)
    end

  end

end