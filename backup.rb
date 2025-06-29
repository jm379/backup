#!/usr/bin/env ruby

require 'bundler/setup'
require_relative 'lib/config'
require_relative 'lib/watcher'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity[0]}, [#{datetime.iso8601(3)} PID: ##{Process.pid} TID: ##{Thread.current.native_thread_id}] #{severity} -- #{progname}: #{msg}\n"
end
config = Config.new path: 'config.yml'
watcher = Watcher.new(config:, logger:)
watcher.start
