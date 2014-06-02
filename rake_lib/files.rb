require 'fileutils'
require 'forwardable'

module AppiumIo
  module Files
    extend Forwardable

    # Avoid having to type 'File.' to use these common methods
    def_delegators File, :exist?, :exists?, :basename, :expand_path, :dirname,
                   :directory?
    def_delegators FileUtils, :mkdir_p, :rm_rf

    # Join the paths then expand the path
    # Paths that are joined and not expanded cause problems
    def join *args
      File.expand_path File.join(*args)
    end

    # Copies source to dest. The destination is created if it doesn't exist
    # If the destination does exist then it will be overridden.
    def copy_entry source, dest
      source = expand_path source
      raise "Source must exist. #{source}" unless exist?(source)

      dest = expand_path dest
      raise 'source must not equal dest' if source == dest
      # copy_entry '/a/b/c.png', '/e/f' => copies to /e/f/c.png
      dest = join(dest, basename(source)) if !directory?(source) && directory?(dest)

      dir_to_make = directory?(dest) ? dest : dirname(dest)
      mkdir_p dir_to_make
      raise "Dest must exist. #{dir_to_make}" unless exist?(dir_to_make)

      FileUtils.copy_entry source, dest, preserve = false,
                           dereference_root       = false,
                           remove_destination     = true
    end
  end
end