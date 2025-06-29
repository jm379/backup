require 'psych'

class Config
  attr_reader :config

  def initialize(path: 'config.yml')
    @config = Psych.safe_load_file path
  end

  def directories(&)
    @config['directories'].each do
      yield it
    end
  end
end
