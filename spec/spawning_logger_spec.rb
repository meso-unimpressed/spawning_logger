require 'tmpdir'
require 'spec_helper'
require 'spawning_logger'

describe SpawningLogger do
  it 'has a version' do
    expect(described_class::VERSION).not_to be_nil
  end
end
