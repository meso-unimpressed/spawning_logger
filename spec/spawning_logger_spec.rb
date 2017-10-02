require 'tmpdir'
require 'spec_helper'
require 'spawning_logger'

describe SpawningLogger do
  subject(:logger) { described_class.new('test') }

  around do |example|
    described_class.configure do |config|
      config.backend = Module.new
    end
    example.run
    FileUtils.remove_entry('development') if Dir.exist?('development')
  end

  describe '#spawn' do
    it 'raises an error if child id is nil' do
      expect { logger.spawn(nil) }.to raise_error(ArgumentError)
    end

    it 'raises an error if child id is empty' do
      expect { logger.spawn }.to raise_error(ArgumentError)
    end

    it('caches spawned loggers') { skip('NYI') }
  end
end
