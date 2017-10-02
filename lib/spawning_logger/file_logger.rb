require 'logger'
require 'spawning_logger/base_logger'

module SpawningLogger
  class FileLogger < BaseLogger
    class << self
      attr_accessor :subdir
    end

    # creates the logfile inside a subdir (optional).
    def initialize(file_path, debug = false)
      file_path = ::File.expand_path(file_path)

      @log_base_dir = ::File.dirname(file_path)

      @log_dir = @log_base_dir
      if self.class.subdir
        @log_dir = ::File.join(@log_dir, self.class.subdir)
      end

      FileUtils.mkdir_p(@log_dir) if !Dir.exist?(@log_dir)

      @file_name = ::File.basename(file_path)

      # this creates the main logger
      super(::Logger.new(::File.join(@log_dir, @file_name)))
    end

    # creates a logger for child_name. uses child_name and
    # child_prefix (if configured) for construction of the new logger's filename.
    #
    # example:
    #   origfile.log => origfile_childprefix_childname.log
    #
    def create_child_logger(child_name)
      # remove extension
      parent_filename = ::File.basename(
        @file_name, ::File.extname(@file_name)
      )

      # add child_prefix + child_id
      file_basename = [
        parent_filename, self.class.child_prefix, child_name
      ].compact.join('_')

      # add extension
      file_name = file_basename + ::File.extname(@file_name)

      # use base dir without subdir, because child logger adds it itself
      file_path = ::File.join(@log_base_dir, file_name)
      self.class.new(file_path)
    end
  end
end
