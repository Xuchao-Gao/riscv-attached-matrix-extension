#!/usr/bin/env ruby
# frozen_string_literal: true

# Ensure every AmeOperation used by an instruction whose encoding is managed by
# the central registry is represented in the shared ame_op semantic contract.

instructions_path = File.join(__dir__, "..", "src", "instructions.adoc")
functions_path = File.join(__dir__, "..", "src", "functions.adoc")
programming_model_path = File.join(__dir__, "..", "src", "programming_model.adoc")

managed_instructions = []
instruction = nil
File.foreach(instructions_path) do |line|
  heading = line.match(/^=== `([^`]+)`/)
  instruction = heading[1] if heading
  managed_instructions << instruction if instruction && line.include?("{ame-enc-")
end
managed_instructions.uniq!

operations = []
instruction = nil
managed = false
File.foreach(instructions_path) do |line|
  heading = line.match(/^=== `([^`]+)`/)
  if heading
    instruction = heading[1]
    managed = managed_instructions.include?(instruction)
  end
  operations.concat(line.scan(/AmeOperation::([A-Z0-9]+)/).flatten) if managed
end
operations.uniq!

contract = File.read(functions_path)
missing = operations.reject { |operation| contract.include?("`#{operation}`") }
unless missing.empty?
  abort "managed AmeOperation values missing from ame_op contract: #{missing.sort.join(', ')}"
end

programming_model = File.read(programming_model_path)
missing_from_programming_model = managed_instructions.reject do |name|
  programming_model.include?(",#{name}>>")
end
unless missing_from_programming_model.empty?
  abort "managed instructions missing from programming model: #{missing_from_programming_model.sort.join(', ')}"
end

puts "checked #{operations.length} managed AmeOperation values and #{managed_instructions.length} programming-model entries"
