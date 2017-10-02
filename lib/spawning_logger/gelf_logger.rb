require 'spawning_logger/base_logger'

module SpawningLogger
  class GelfLogger < BaseLogger
    class << self
      attr_accessor :separator
    end

    self.separator = '_'

    def initialize(*args)
      @args = args.dup
      @options = @args.last.is_a?(Hash) ? @args.pop : {}
      @options[:_instance] ||= 'root'
      super(::GELF::Logger.new(*@args, @options))
    end

    # creates a logger for child_name. uses child_name and
    # child_prefix (if configured) for construction of the new logger's
    # instance name.
    #
    # example:
    #   orig => orig_childprefix_childname
    #
    def create_child_logger(child_name)
      # add child_prefix + child_id
      instance_name = [
        @options[:_instance], self.class.child_prefix, child_name
      ].compact.join(self.class.separator)

      self.class.new(*@args, @options.merge(_instance: instance_name))
    end

  end
end
