#!/usr/bin/env ruby
# frozen_string_literal: true

# Ensure every AmeOperation covered by the shared ame_op/ame_op3 semantic
# contract is used consistently and its instruction is represented in the
# programming model.  Semantic-contract membership is intentionally
# independent of encoding attributes: common funct3/bank attributes are now
# used by every instruction.

instructions_path = File.join(__dir__, "..", "src", "instructions.adoc")
functions_path = File.join(__dir__, "..", "src", "functions.adoc")
programming_model_path = File.join(__dir__, "..", "src", "programming_model.adoc")

instruction_operations = Hash.new { |hash, key| hash[key] = [] }
instruction = nil
File.foreach(instructions_path) do |line|
  heading = line.match(/^=== `([^`]+)`/)
  instruction = heading[1] if heading
  instruction_operations[instruction].concat(line.scan(/AmeOperation::([A-Z0-9]+)/).flatten) if instruction
end
instruction_operations.transform_values!(&:uniq)

contract = File.read(functions_path)
contract_operations = contract.scan(/`([A-Z][A-Z0-9]+1D)`/).flatten.uniq
managed_instructions = instruction_operations.select do |_name, operations|
  !(operations & contract_operations).empty?
end
operations = managed_instructions.values.flatten.uniq

missing = operations - contract_operations
abort "managed AmeOperation values missing from ame_op contract: #{missing.sort.join(', ')}" unless missing.empty?
unused = contract_operations - operations
abort "ame_op contract contains unused AmeOperation values: #{unused.sort.join(', ')}" unless unused.empty?

programming_model = File.read(programming_model_path)
missing_from_programming_model = managed_instructions.keys.reject do |name|
  programming_model.include?(",#{name}>>")
end
unless missing_from_programming_model.empty?
  abort "managed instructions missing from programming model: #{missing_from_programming_model.sort.join(', ')}"
end

puts "checked #{operations.length} contract-managed AmeOperation values and #{managed_instructions.length} programming-model entries"
