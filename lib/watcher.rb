require_relative 'backup/worker'
require_relative 'backup/notifier'

class Watcher
  attr_reader :config, :logger, :notifier, :queue

  def initialize(config:, logger:)
    @config = config
    @logger = logger
    @queue = Thread::Queue.new
  end

  def start
    Thread.current.name = 'Watcher'
    worker = Backup::Worker.new(logger:, queue:).start
    notifier = Backup::Notifier.new(logger:, config:, queue:).start

    begin
      notifier.run
    rescue Interrupt => e
      logger.info(Thread.current.name) { 'Received SIGINT, Exiting' }
      notifier.stop
      worker.stop
      logger.close
    end
  end
end
