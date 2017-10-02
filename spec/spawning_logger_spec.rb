require 'tmpdir'
require 'spec_helper'
require 'spawning_logger'

describe SpawningLogger do
  let(:log_base_dir) { Dir.mktmpdir('spawning_logger_test') }
  let(:log_dir) { File.join(log_base_dir, 'test_subdir') }
  let(:logfile_name) { 'test_file.log' }
  let(:logfile_path) { File.join(log_base_dir, logfile_name) }
  let(:child_id) { 'childid' }

  around do |example|
    reset_logger_config
    example.run
    FileUtils.remove_entry(log_base_dir)
    reset_logger_config
  end

  matcher :create_log_file do |file_name|
    supports_block_expectations

    match do |block|
      pathname = Pathname.new(log_dir) + file_name
      existed_before = pathname.exist?
      block.call
      !existed_before && pathname.exist? && pathname.file?
    end
  end

  context 'with a subdirectory' do
    let(:subdir) { 'development' }
    before { described_class.configure { |config| config.subdir = subdir } }

    it "creates a subdir if it doesn't exist" do
      expected_file = File.join(log_base_dir, subdir, logfile_name)
      described_class.new(logfile_path, true)
      expect(Pathname.new(expected_file)).to(exist && be_file)
    end
  end

  describe '#spawn' do
    subject(:logger) { described_class.new(logfile_path) }

    it 'returns a logger for the given child id' do
      expect { logger.spawn('childid') }.to(
        create_log_file('test_file_childid.log')
      )
    end

    context 'with child prefix' do
      before do
        described_class.configure do |config|
          config.child_prefix = 'childprefix'
        end
      end

      it 'includes child prefix in filename' do
        expect { logger.spawn('childid') }.to(
          create_log_file('test_file_childprefix_childid.log')
        )
      end
    end

    it 'raises an error if child id is nil' do
      expect { logger.spawn(nil) }.to raise_error(SpawningLogger::ArgumentError)
    end

    it 'raises an error if child id is empty' do
      expect { logger.spawn }.to raise_error(ArgumentError)
    end

    context 'recursive spawning' do
      subject(:child) { logger.spawn('child1') }

      it 'results in yet another spawning logger instance' do
        sub_child = child.spawn('child2')
        expect(sub_child).to be_a(described_class)
      end

      it 'creates the expected log file' do
        expect { child.spawn('child2') }.to(
          create_log_file('test_file_child1_child2.log')
        )
      end
    end

    it('caches spawned loggers') { skip('NYI') }
  end

  private

  def reset_logger_config
    described_class.configure do |config|
      config.child_prefix = nil
      config.subdir = 'test_subdir'
    end
  end
end
