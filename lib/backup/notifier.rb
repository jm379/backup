require 'rb-inotify'
require_relative 'job'
require_relative 'adapters'

module Backup
  class Notifier
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

        notifier.watch(File.expand_path(adapter.path), *EVENTS, :recursive) do |event|
          begin
            job = Job.new(adapter:, event:)
            queue.push job
            logger.debug('Notifier') { "Enqueued #{job.name} job caused by the event(s) #{event.flags} on #{event.absolute_name}" }
          rescue => e
            logger.error('Notifier') { "Failed to enqueue #{job&.name || 'Unknown'} job with event: #{event.flags} on #{event.absolute_name}: #{e.message}" }
          end
        end
      end

      self
    end

    def stop
      logger.info(Thread.current.name) { 'Stopping Notifier' }
      notifier.close
    end

    def run
      notifier.run
    end
  end
end
