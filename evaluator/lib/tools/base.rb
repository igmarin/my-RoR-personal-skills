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
        # @param working_dir_path [Pathname] The expanded pathname of the working directory.
        # @return [Pathname] The fully expanded and secure path.
        # @raise [RuntimeError] If the path attempts to traverse outside the working directory.
        def secure_path(path, working_dir_path)
          working_dir_real = working_dir_path.realpath
          full_path = working_dir_real.join(path).expand_path
          raise "Path traversal is not allowed: #{path}" unless full_path.to_s.start_with?(working_dir_real.to_s)

          verify_symlink_safety(full_path, working_dir_real, path)

          full_path
        end

        private

        def verify_symlink_safety(full_path, working_dir_real, original_path)
          path_to_check = full_path.exist? ? full_path : full_path.dirname
          return unless path_to_check.exist?

          real_path = path_to_check.realpath
          return if real_path.to_s.start_with?(working_dir_real.to_s)

          raise "Symlink path traversal is not allowed: #{original_path}"
        end
      end
    end
  end
end
