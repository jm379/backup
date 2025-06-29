module Backup
  class Job
    attr_reader :adapter, :event

    def initialize(adapter:, event:)
      @adapter = adapter
      @event = event
    end

    def run
      adapter.call(event)
    end

    def hash
      @hash ||= adapter.hash
    end

    def name
      adapter.class.name
    end
  end
end
