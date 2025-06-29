#!/usr/bin/env ruby

require 'bundler/inline'
require_relative 'lib/config'
require_relative 'lib/watcher'

gemfile do
  source 'https://rubygems.org'

  gem 'base64'
  gem 'logger'
  gem 'rb-inotify'
end

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
config = Config.new path: 'config.yml'
watcher = Watcher.new(config:, logger:)
watcher.start
