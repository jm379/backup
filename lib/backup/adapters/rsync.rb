require 'base64'
require 'logger'
require_relative 'backup'

module Backup
  class Adapters
    class Rsync < Backup
      attr_reader :config, :logger

      def initialize(config, logger:)
        @config = config
        @logger = logger
      end

      def call(event)
        info "Backing up #{path} to #{output}"
        pid = spawn cmd
        Process.wait pid
        info 'done'
      end

      def cmd
        @cmd ||= "rsync --mkpath --delete -azL #{path} #{output}"
      end

      def hash
        @hash ||= Base64.encode64 cmd
      end

      def path
        config['path']
      end

      def output
        config['output']
      end

      def info(msg)
        logger.info(progname) { msg }
      end

      def progname
        self.class.name
      end
    end
  end
end
