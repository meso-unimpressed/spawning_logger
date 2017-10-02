shared_examples :base_logger do |*args|
  describe '#spawn' do
    subject(:logger) { described_class.new(*args) }

    it 'raises an error if child id is nil' do
      expect { logger.spawn(nil) }.to raise_error(ArgumentError)
    end

    it 'raises an error if child id is empty' do
      expect { logger.spawn }.to raise_error(ArgumentError)
    end

    it('caches spawned loggers') { skip('NYI') }
  end
end
