#!/usr/bin/env ruby

require 'bundler/setup'
require_relative 'lib/config'
require_relative 'lib/watcher'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
config = Config.new path: 'config.yml'
watcher = Watcher.new(config:, logger:)
watcher.start
