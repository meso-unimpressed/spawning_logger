class SpawningLogger < SimpleDelegator
  module Backends
    AVAILABLE_BACKENDS = {
      'File': 'spawning_logger/backends/file',
      'GELF': 'spawning_logger/backends/gelf'
    }.freeze

    AVAILABLE_BACKENDS.each do |name, path|
      autoload(name, path)
    end
  end
end
