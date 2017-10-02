require 'spawning_logger/base_logger'

module SpawningLogger
  class MultiLogger < BaseLogger
    def initialize(*loggers)
      @loggers = loggers
      super(nil)
    end

    def create_child_logger(*args)
      child_loggers = @loggers.flat_map do |logger|
        logger.create_child_logger(*args)
      end

      self.class.new(*child_loggers)
    end

    def method_missing(name, *arguments)
      @loggers.each do |logger|
        return super unless logger.respond_to?(name)
      end

      self.class.send(:define_method, name) do |*args|
        @loggers.each { |logger| logger.public_send(name, *args) }
      end

      public_send(name, *arguments)
    end
  end
end
