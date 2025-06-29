require 'rb-inotify'
require_relative 'backup/adapters'
require_relative 'backup/job'
require_relative 'backup/worker'

class Watcher
  attr_reader :config, :logger, :notifier, :queue, :stop

  def initialize(config:, logger:)
    @config = config
    @logger = logger
    @notifier = INotify::Notifier.new
    @queue = Thread::Queue.new
    @stop = false
  end

  def start
    Thread.current.name = 'Watcher'
    worker = Backup::Worker.new(logger:, queue:).start

    config.directories do |config|
      adapter = Backup::Adapters.adapter(config, logger:)

      notifier.watch(File.expand_path(adapter.path), *events, :recursive) do |event|
        queue.push Backup::Job.new(adapter:, event:)
      end
    end

    begin
      notifier.run
    rescue Interrupt => e
      logger.info(Thread.current.name) { 'Received SIGINT, Exiting' }
      notifier.close
      worker.stop
      logger.close
    end
  end

  def events
    %i[create modify delete move close_write attrib]
  end
end
