require 'spec_helper'
require 'spawning_logger'
require 'spawning_logger/shared_examples/base_logger'

describe SpawningLogger::MultiLogger do
  LOG_FILES = %w(one.log two.log three.log)
  include_examples(
    :base_logger, LOG_FILES.map(&SpawningLogger::FileLogger.method(:new))
  )

  after do
    LOG_FILES.each do |file|
      FileUtils.remove_entry(file) if File.exist?(file)
    end
  end

  subject(:logger) { described_class.new(*loggers) }
  let(:loggers) { LOG_FILES.map(&SpawningLogger::FileLogger.method(:new)) }

  describe '#spawn' do
    before do
      loggers.each do |sub_logger|
        allow(sub_logger).to receive(:create_child_logger)
      end
    end

    it 'delegates to all underlying loggers' do
      logger.spawn('test')
      expect(loggers).to all(have_received(:create_child_logger).with('test'))
    end
  end

  it 'delegates public methods to underlying loggers' do
    loggers.each { |sub_logger| allow(sub_logger).to receive(:debug) }
    logger.debug('test')
    expect(loggers).to all(have_received(:debug).with('test'))
  end
end
