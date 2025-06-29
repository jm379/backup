require_relative 'backup/worker'
require_relative 'backup/enqueuer'

class Watcher
  attr_reader :config, :logger, :notifier, :queue

  def initialize(config:, logger:)
    @config = config
    @logger = logger
    @queue = Thread::Queue.new
  end

  def start
    Thread.current.name = progname
    worker = Backup::Worker.new(logger:, queue:).start
    enqueuer = Backup::Enqueuer.new(logger:, config:, queue:)

    begin
      enqueuer.start
    rescue Interrupt => e
      logger.info(progname) { 'Received SIGINT, Exiting' }
      enqueuer.stop
      worker.stop
      logger.close
    end
  end

  def progname
    self.class.name
  end
end
