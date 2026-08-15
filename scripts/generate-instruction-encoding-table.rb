#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/instruction_encoding_renderer"

root = File.expand_path("..", __dir__)

begin
  instruction_set = AmeEncoding::InstructionSet.new(root: root).validate!
  renderer = AmeEncoding::InstructionEncodingRenderer.new(instruction_set)

  if ARGV == ["--check"]
    renderer.check!
    puts "checked generated encoding artifacts: #{instruction_set.entries.length} entries are current"
  elsif ARGV.empty?
    renderer.write!
    puts "wrote INSTRUCTION_ENCODINGS.md and the normative allocation table " \
         "with #{instruction_set.entries.length} instruction encodings"
  else
    abort "usage: #{$PROGRAM_NAME} [--check]"
  end
rescue AmeEncoding::ValidationError => error
  abort "instruction-encoding generation failed:\n  #{error.message.gsub("\n", "\n  ")}"
end
