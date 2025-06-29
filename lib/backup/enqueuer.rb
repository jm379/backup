require 'rb-inotify'
require_relative 'job'
require_relative 'adapters'

module Backup
  class Enqueuer
    attr_reader :config, :logger, :queue, :notifier
    EVENTS = %i[create modify delete move close_write attrib].freeze

    def initialize(config:, logger:, queue:)
      @config = config
      @logger = logger
      @queue = queue
      @notifier = INotify::Notifier.new
    end

    def start
      config.directories do |config|
        adapter = Adapters.adapter(config:, logger:)

        logger.info(progname) { "Watching #{adapter.path}" }
        notifier.watch(File.expand_path(adapter.path), *EVENTS, :recursive) do |event|
          begin
            job = Job.new(adapter:, event:)
            queue.push job
            logger.debug(progname) { "Enqueued #{job.name} job caused by the event(s) #{event.flags} on #{event.absolute_name}" }
          rescue => e
            logger.error(progname) { "Failed to enqueue #{job&.name || 'Unknown'} job with event: #{event.flags} on #{event.absolute_name}: #{e.message}" }
          end
        end
      end

      logger.info(progname) { 'Enqueuer started' }
      notifier.run
    end

    def stop
      logger.info(Thread.current.name) { 'Stopping Enqueuer' }
      notifier.close
    end

    def progname
      self.class.name
    end
  end
end
