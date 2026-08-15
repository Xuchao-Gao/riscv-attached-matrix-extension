#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/instruction_encoding_renderer"

root = File.expand_path("..", __dir__)

begin
  instruction_set = AmeEncoding::InstructionSet.new(root: root).validate!
  AmeEncoding::InstructionEncodingRenderer.new(instruction_set).check!
rescue AmeEncoding::ValidationError => error
  abort "instruction-encoding validation failed:\n  #{error.message.gsub("\n", "\n  ")}"
end

counts = instruction_set.format_counts
puts "checked #{instruction_set.entries.length} instruction encodings " \
     "(R3=#{counts.fetch('R3', 0)}, R2=#{counts.fetch('R2', 0)}, " \
     "R1=#{counts.fetch('R1', 0)}, Fixed=#{counts.fetch('Fixed', 0)}): " \
     "schema-backed allocation, 32-bit field fit, fixed opcode/funct3 skeleton, " \
     "format/bank ownership, dense selector use, mnemonic/operand agreement, " \
     "no overlaps, and generated artifacts current"
