#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

ROOT = File.expand_path("..", __dir__)
SOURCE = File.join(ROOT, "tessl-evals")
DEFAULT_DESTINATION = File.join(ROOT, "evals")
DESTINATION = File.expand_path(ARGV[0] || DEFAULT_DESTINATION, ROOT)

abort "Missing tessl-evals/ source directory" unless Dir.exist?(SOURCE)
abort "Refusing to stage outside the repository: #{DESTINATION}" unless DESTINATION.start_with?(ROOT)

FileUtils.rm_rf(DESTINATION)
FileUtils.mkdir_p(DESTINATION)

Dir.children(SOURCE).sort.each do |entry|
  source_path = File.join(SOURCE, entry)
  next unless File.directory?(source_path)

  FileUtils.cp_r(source_path, File.join(DESTINATION, entry))
end

puts "Staged Tessl eval scenarios into #{DESTINATION.sub("#{ROOT}/", "")}"
