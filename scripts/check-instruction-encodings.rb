#!/usr/bin/env ruby
# frozen_string_literal: true

# Check every instruction encoding for malformed fields, diagram/decode
# mismatches, exact duplicates, and partial decode-space overlaps.

attributes_path = File.join(__dir__, "..", "src", "instruction-encoding-allocations.adoc")
instructions_path = File.join(__dir__, "..", "src", "instructions.adoc")

attributes = {}
File.foreach(attributes_path) do |line|
  match = line.match(/^:([a-z0-9-]+):\s+(\S+)$/)
  attributes[match[1]] = match[2] if match
end

abort "no managed encoding attributes found" if attributes.empty?

entries = []
instruction = nil
used_attributes = []

File.foreach(instructions_path) do |line|
  heading = line.match(/^=== `([^`]+)`/)
  instruction = heading[1] if heading
  next unless instruction && line.start_with?("{\"reg\":")

  resolved = line.gsub(/\{([a-z0-9-]+)\}/) do
    name = Regexp.last_match(1)
    abort "unknown encoding attribute {#{name}} in #{instruction}" unless attributes.key?(name)

    used_attributes << name
    attributes[name]
  end

  resolved.scan(/"bits":(\d+),"name":\s*(0x[0-9a-f]+|\d+)/).each do |width_text, value_text|
    width = width_text.to_i
    field_value = value_text.start_with?("0x") ? value_text.to_i(16) : value_text.to_i
    abort "#{instruction} encoding value #{value_text} does not fit in #{width} bits" if field_value >= (1 << width)
  end

  # Build a fixed-bit mask/value pair.  Exact WaveDrom equality is insufficient
  # for detecting overlap between an encoding with a variable operand field and
  # a more-specific encoding that fixes some of those operand bits.
  position = 0
  mask = 0
  value = 0
  resolved.scan(/"bits":(\d+),"name":\s*("[^"]+"|0x[0-9a-f]+|\d+)/) do |width_text, token|
    width = width_text.to_i
    unless token.start_with?('"')
      field_value = token.start_with?("0x") ? token.to_i(16) : token.to_i
      field_mask = ((1 << width) - 1) << position
      mask |= field_mask
      value |= field_value << position
    end
    position += width
  end
  abort "#{instruction} encoding is #{position} bits, expected 32" unless position == 32

  entries << { name: instruction, mask: mask, value: value }
end

unused = attributes.keys - used_attributes.uniq
abort "unused managed encoding attributes: #{unused.sort.join(', ')}" unless unused.empty?

# Keep every WaveDrom operand field synchronized with the normative
# Decode Variables block.  Collision checking alone cannot detect a diagram
# that assigns an operand to different bits than the pseudocode reads.
field_errors = []
File.read(instructions_path).scan(/^=== `([^`]+)`\n(.*?)(?=^=== `|\z)/m) do |name, section|
  diagram = section.lines.find { |line| line.start_with?('{"reg":') }
  next unless diagram

  position = 0
  fields = {}
  diagram.scan(/"bits":(\d+),"name":\s*(\{[^}]+\}|"[^"]+"|0x[0-9a-f]+|\d+)/) do |width_text, token|
    width = width_text.to_i
    fields[token[1...-1]] = [position + width - 1, position] if token.start_with?('"')
    position += width
  end

  decoded = {}
  section.scan(/(?:Bits|UInt|SInt)<\d+>\s+(\w+)\s*=\s*\$encoding\[(\d+)(?::(\d+))?\]/) do |field, hi, lo|
    decoded[field] = [hi.to_i, (lo || hi).to_i]
  end

  fields.each do |field, range|
    if !decoded.key?(field)
      field_errors << "#{name} does not decode operand #{field} from diagram bits #{range.join(':')}"
    elsif decoded[field] != range
      field_errors << "#{name} operand #{field}: diagram #{range.join(':')}, decode #{decoded[field].join(':')}"
    end
  end
end
abort "managed encoding/decode mismatch:\n  #{field_errors.join("\n  ")}" unless field_errors.empty?

collisions = entries.combination(2).select do |left, right|
  common_mask = left[:mask] & right[:mask]
  ((left[:value] ^ right[:value]) & common_mask).zero?
end

unless collisions.empty?
  collisions.each do |left, right|
    kind = left[:mask] == right[:mask] && left[:value] == right[:value] ? "exact duplicate" : "decode overlap"
    warn "instruction encoding #{kind}: #{left[:name]}, #{right[:name]}"
  end
  exit 1
end

puts "checked #{entries.length} instruction encodings: fields match decode variables; no duplicates or overlaps"
