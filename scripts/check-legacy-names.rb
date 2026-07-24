#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"

# Keep names from the retired external document-generation pipeline out of the
# standalone AME sources. Construct the token so this checker does not preserve
# the legacy name merely to prohibit it.

root = File.expand_path("..", __dir__)
legacy_token = %w[u db].join
errors = []

Dir.glob("{Makefile,*.md,*.adoc,src/**/*.adoc,scripts/**/*}", base: root).sort.each do |relative_path|
  path = File.join(root, relative_path)
  next unless File.file?(path)
  next if File.expand_path(path) == __FILE__

  content = File.binread(path)
  text = content.force_encoding(Encoding::UTF_8)
  next unless text.valid_encoding?

  text.each_line.with_index(1) do |line, line_number|
    errors << "#{relative_path}:#{line_number}" if line.downcase.include?(legacy_token)
  end
end

abort "legacy generator names remain:\n  #{errors.join("\n  ")}" unless errors.empty?

adoc = Dir.glob("src/*.adoc", base: root).map { |path| File.read(File.join(root, path)) }.join("\n")
anchors = adoc.scan(/\[(?:#|\[)(ame:doc:[^\]\s]+)\]?\]/).flatten.to_set
references = adoc.scan(/<<(ame:doc:[^,>]+)(?:,[^>]*)?>>/).flatten.to_set
missing = references - anchors

abort "standalone document references missing targets:\n  #{missing.to_a.sort.join("\n  ")}" unless missing.empty?

puts "checked standalone sources: no legacy generator names and no missing internal targets"
