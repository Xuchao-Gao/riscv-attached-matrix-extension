#!/usr/bin/env ruby
# frozen_string_literal: true

# Check that encodings driven by the central provisional registry do not
# collide with any other encoding in instructions.adoc.

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

  managed = line.include?("{ame-enc-")
  resolved = line.gsub(/\{([a-z0-9-]+)\}/) do
    name = Regexp.last_match(1)
    abort "unknown encoding attribute {#{name}} in #{instruction}" unless attributes.key?(name)

    used_attributes << name
    attributes[name]
  end

  if managed
    resolved.scan(/"bits":(\d+),"name":\s*(0x[0-9a-f]+|\d+)/).each do |width_text, value_text|
      width = width_text.to_i
      value = value_text.start_with?("0x") ? value_text.to_i(16) : value_text.to_i
      abort "#{instruction} encoding value #{value_text} does not fit in #{width} bits" if value >= (1 << width)
    end
  end

  # Operand names do not contribute to the fixed decode pattern.  Field widths,
  # fixed values, and field positions remain part of the signature.
  signature = resolved.gsub(/"name":\s*"[^"]+"/, '"name":"*"').gsub(/\s+/, "")
  entries << { name: instruction, signature: signature, managed: managed }
end

unused = attributes.keys - used_attributes.uniq
abort "unused managed encoding attributes: #{unused.sort.join(', ')}" unless unused.empty?

# Keep each managed WaveDrom operand field synchronized with the normative
# Decode Variables block.  Collision checking alone cannot detect a diagram
# that assigns an operand to different bits than the pseudocode reads.
field_errors = []
File.read(instructions_path).scan(/^=== `([^`]+)`\n(.*?)(?=^=== `|\z)/m) do |name, section|
  next unless section.include?("{ame-enc-")

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

collisions = entries.group_by { |entry| entry[:signature] }.values.select do |group|
  group.length > 1 && group.any? { |entry| entry[:managed] }
end

unless collisions.empty?
  collisions.each do |group|
    warn "managed encoding collision: #{group.map { |entry| entry[:name] }.join(', ')}"
  end
  exit 1
end

managed_count = entries.count { |entry| entry[:managed] }
puts "checked #{managed_count} managed instruction encodings: no collisions"
