require 'abstractize'

module SpawningLogger
  class BaseLogger < SimpleDelegator
    include Abstractize

    class ArgumentError < ::ArgumentError; end

    class << self
      attr_accessor :child_prefix

      def configure
        yield self
      end
    end

    def initialize(logger)
      @child_loggers = {} # these are the special sub-loggers
      super
    end

    # creates a sub logger with filename <orig_file>_<child_prefix>_<child_name>.log
    # example: see class docstring or README.md
    def spawn(child_name)
      raise ArgumentError.new("empty child_name") if child_name.to_s.empty?

      @child_loggers[child_name] ||= create_child_logger(child_name)
      @child_loggers[child_name]
    end

    # logs into the main logfile and also logs into a spawned logfile.
    # @param child_name the child to spawn and log into
    # @param method the method name to call, like :error, :info, :debug, ...
    # @param message the message to send to both loggers
    def self_and_spawn(child_name, method, message)
      self.send(method, message)
      self.spawn(child_name).send(method, message)
    end

    define_abstract_method :create_child_logger
  end
end
