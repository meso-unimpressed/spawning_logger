require 'spec_helper'
require 'tmpdir'
require 'spawning_logger'
require 'spawning_logger/shared_examples/base_logger'

describe 'SpawningLogger::GelfLogger' do
  let(:described_class) { SpawningLogger::GelfLogger }
  let(:gelf_logger_class) do
    Class.new do
      def initialize(*)
      end
    end
  end

  let(:ip) { '127.0.0.1' }
  let(:port) { '1234' }
  let(:type) { 'WAN' }

  before do
    allow(Kernel).to receive(:require).with('gelf')
    require 'spawning_logger/gelf_logger.rb'
    stub_const('GELF::Logger', gelf_logger_class)
    reset_logger_config
  end

  include_examples :base_logger

  matcher :create_a_gelf_logger_with_instance_name do |instance_name|
    supports_block_expectations

    match do |block|
      allow(gelf_logger_class).to receive(:new)
      block.call
      expect(gelf_logger_class).to have_received(:new).with(
        anything, anything, anything, hash_including(_instance: instance_name)
      )
    end
  end

  describe '.new' do
    it 'uses root as default instance name' do
      expect { described_class.new(ip, port, type) }.to(
        create_a_gelf_logger_with_instance_name('root')
      )
    end
  end

  describe '#spawn' do
    subject(:logger) { described_class.new(ip, port, type) }

    it 'returns a logger for the given child id' do
      expect { logger.spawn('childid') }.to(
        create_a_gelf_logger_with_instance_name('root_childid')
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
          create_a_gelf_logger_with_instance_name('root_childprefix_childid')
        )
      end
    end

    context 'recursive spawning' do
      subject(:child) { logger.spawn('child1') }

      it 'results in yet another spawning logger instance' do
        sub_child = child.spawn('child2')
        expect(sub_child).to be_a(described_class)
      end

      it 'creates the expected log file' do
        expect { child.spawn('child2') }.to(
          create_a_gelf_logger_with_instance_name('root_child1_child2')
        )
      end
    end
  end

  private

  def reset_logger_config
    described_class.configure do |config|
      config.child_prefix = nil
    end
  end
end
