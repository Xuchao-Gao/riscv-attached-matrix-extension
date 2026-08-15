#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"

root = File.expand_path("..", __dir__)
archive_dir = ["legacy", %w[u db].join].join("-")
archive_path = File.join(root, "formal", archive_dir)
readme_path = File.join(archive_path, "README.md")
errors = []

unless File.file?(readme_path)
  abort "frozen-archive validation failed:\n  missing #{readme_path}"
end

readme = File.read(readme_path)
source_section = readme[/^Snapshot source:\s*\n\n(.*?)(?=\n\n)/m, 1]
if source_section.nil?
  errors << "README.md: missing Snapshot source metadata"
else
  provenance = source_section.scan(/^- ([^:]+): `([^`]+)`\s*$/).to_h
  expected_provenance = {
    "Repository" => "riscv/riscv-attached-matrix-extension",
    "Baseline commit" => "b97c6c4656525ee06aeb9600021b1debc0a76233",
    "Baseline tag" => "v0.5"
  }
  expected_provenance.each do |field, expected|
    actual = provenance[field]
    errors << "README.md: #{field} is #{actual.inspect}, expected #{expected.inspect}" unless actual == expected
  end
end

frozen_section = readme[/^## Frozen files\s*$\n(.*?)(?=^## |\z)/m, 1]
frozen_files = {}
if frozen_section.nil?
  errors << "README.md: missing Frozen files table"
else
  unless frozen_section.match?(/^\|\s*File\s*\|\s*SHA-256\s*\|\s*$/)
    errors << "README.md: Frozen files table is missing its header"
  end
  unless frozen_section.match?(/^\|\s*-+\s*\|\s*-+\s*\|\s*$/)
    errors << "README.md: Frozen files table is missing its separator"
  end

  frozen_section.each_line do |line|
    next unless line.lstrip.start_with?("|")
    next if line.match?(/^\|\s*File\s*\|\s*SHA-256\s*\|\s*$/)
    next if line.match?(/^\|\s*-+\s*\|\s*-+\s*\|\s*$/)

    match = line.match(/^\|\s*`([^`]+)`\s*\|\s*`([0-9a-f]{64})`\s*\|\s*$/)
    unless match
      errors << "README.md: malformed Frozen files row #{line.strip.inspect}"
      next
    end

    filename = match[1]
    digest = match[2]
    if filename != File.basename(filename)
      errors << "README.md: frozen filename must be a basename: #{filename.inspect}"
      next
    end
    errors << "README.md: duplicate frozen filename #{filename}" if frozen_files.key?(filename)
    frozen_files[filename] = digest
  end
  errors << "README.md: Frozen files table has no file rows" if frozen_files.empty?
end

archive_entries = Dir.children(archive_path).reject { |entry| entry == "README.md" }.sort
listed_entries = frozen_files.keys.sort
unless archive_entries == listed_entries
  missing = listed_entries - archive_entries
  unlisted = archive_entries - listed_entries
  errors << "archive files missing from disk: #{missing.join(', ')}" unless missing.empty?
  errors << "archive entries missing from README.md: #{unlisted.join(', ')}" unless unlisted.empty?
end

frozen_files.each do |filename, expected|
  path = File.join(archive_path, filename)
  unless File.file?(path) && !File.symlink?(path)
    errors << "#{filename}: frozen archive entry is not a regular file"
    next
  end

  actual = Digest::SHA256.file(path).hexdigest
  errors << "#{filename}: SHA-256 is #{actual}, expected #{expected}" unless actual == expected
end

abort "frozen-archive validation failed:\n  #{errors.join("\n  ")}" unless errors.empty?

puts "checked #{frozen_files.length} frozen archive files against the README manifest and snapshot provenance"
