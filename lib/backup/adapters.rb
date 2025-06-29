require_relative 'adapters/rsync'

module Backup
  class Adapters
    def self.adapter(config, logger:)
      case config['adapter']
      when 'rsync' then Rsync.new(config, logger:)
      else Rsync.new(config, logger:)
      end
    end
  end
end
