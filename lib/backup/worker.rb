module Backup
  class Worker
    attr_reader :logger, :set, :thr, :queue

    def initialize(logger:, queue:)
      @logger = logger
      @queue = queue
      @set = Set.new
      @stop = false
      @thr = nil
    end

    def start
      @thr = Thread.new do
        loop do
          if @stop
            logger.info(Thread.current.name) { 'Exiting' }
            thr.exit
          end

          while job = queue.pop(false, timeout: 1) do
            unless set.include?(job.hash)
              set.add job.hash
              begin
                job.run
              rescue => e
                logger.error(Thread.current.name) { "Error running job: #{e.message}" }
              end
            end
          end

          set.clear
        end
      end
      @thr.name = "Worker"

      logger.info(Thread.current.name) { 'Worker started' }
      self
    end

    def stop
      @stop = true

      if @thr.alive?
        logger.info(Thread.current.name) { 'Waiting 10 seconds before forcefully killing worker thread' }
        unless thr.join(10)
          logger.info(Thread.current.name) { 'Forcefully killing worker thread' }
          thr.kill
        end
      end
    end
  end
end
