# frozen_string_literal: true

require 'pathname'

module Evaluator
  module Tools
    # Base functionality for tools, providing common utilities like secure path resolution.
    class Base
      class << self
        protected

        # Sanitizes and resolves a relative path against the working directory.
        # Ensures the resulting path stays within the boundaries of the working directory.
        #
        # @param path [String] The relative path to resolve.
        # @param working_dir_path [Pathname, String] The pathname of the working directory.
        # @return [Pathname] The fully expanded and secure path.
        # @raise [ArgumentError] If path is invalid or attempts traversal.
        def secure_path(path, working_dir_path)
          validate_input!(path, working_dir_path)

          working_dir_real = Pathname.new(working_dir_path).realpath
          working_dir_str = working_dir_real.to_s

          # Use Pathname#join and #cleanpath to resolve '..' and '.' safely
          full_path = working_dir_real.join(path).cleanpath

          # Ensure the path is still within the working directory
          # We check against the string representation and ensure it's not escaping
          # by adding the separator to the prefix check.
          raise ArgumentError, "Path traversal attempt: #{path}" unless full_path.to_s == working_dir_str || full_path.to_s.start_with?(working_dir_str + File::SEPARATOR)

          verify_symlink_safety!(full_path, working_dir_real, working_dir_str, path)

          full_path
        end

        private

        def validate_input!(path, working_dir_path)
          raise ArgumentError, 'Path must be a string' unless path.is_a?(String)
          raise ArgumentError, 'Working directory must be provided' unless working_dir_path
          raise ArgumentError, 'Path cannot be empty' if path.strip.empty?
          raise ArgumentError, 'Absolute paths are not allowed' if path.start_with?('/')
        end

        def verify_symlink_safety!(full_path, working_dir_real, working_dir_str, original_path)
          # Check every component of the path to prevent escaping via intermediate symlinks
          current = full_path
          while current != working_dir_real && current.to_s.length > working_dir_str.length
            if current.exist? || current.symlink?
              begin
                real = current.realpath
                raise ArgumentError, "Symlink escapes sandbox: #{original_path}" unless real.to_s.start_with?(working_dir_str)
              rescue Errno::ENOENT
                # Path component doesn't exist, which is fine for new files
              end
            end
            current = current.dirname
          end
        end
      end
    end
  end
end
