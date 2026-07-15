#!/usr/bin/env ruby
# frozen_string_literal: true

# Catch common formal-pseudocode mistakes that silently reduce an element
# access to one bit or discard all but the last element result.

instructions_path = File.join(__dir__, "..", "src", "instructions.adoc")
programming_model_path = File.join(__dir__, "..", "src", "programming_model.adoc")
lines = File.readlines(instructions_path)
headings = []
lines.each_with_index do |line, index|
  match = line.match(/^=== `([^`]+)`/)
  headings << [match[1], index] if match
end

errors = []
headings.each_with_index do |(instruction, start_line), index|
  end_line = index + 1 < headings.length ? headings[index + 1][1] : lines.length
  section = lines[start_line...end_line]
  bounds = {}

  section.each_with_index do |line, offset|
    match = line.match(/U32\s+(\w+_(?:hi|lo)(?:_idx)?)\s*=\s*(.*);/)
    next unless match

    variable = match[1]
    base = variable.sub(/_(hi|lo)(_idx)?$/, "")
    bound = variable.match(/_(hi|lo)(?:_idx)?$/)[1].to_sym
    (bounds[base] ||= {})[bound] = [match[2].strip, start_line + offset + 1]
  end

  bounds.each do |base, pair|
    next unless pair[:hi] && pair[:lo] && pair[:hi][0] == pair[:lo][0]

    errors << "#{instruction}: #{base} high and low bounds are identical at lines #{pair[:hi][1]}/#{pair[:lo][1]}"
  end

  if section.any? { |line| line.match?(/^\s*Bits<AME_MAX_SQUARE_SIZE> result(?:\s*=\s*[^;]+)?;/) } &&
     section.any? { |line| line.match?(/^\s*result = .*ame_op/) }
    errors << "#{instruction}: scalar ame_op result overwrites a whole-square result buffer"
  end

  support_calls = section.select { |line| line.include?("ame_op_supported") }.map(&:strip)
  support_calls.group_by(&:itself).each do |call, duplicates|
    next unless duplicates.length > 1

    errors << "#{instruction}: duplicate ame_op_supported check: #{call}"
  end

  section.each_with_index do |line, offset|
    next unless line.match?(/(?:M|Acc)\[[^\n]+\]\[[^\n]+\]\s*=\s*.*ame_xform_rm_to_impl/)

    errors << "#{instruction}: whole-square layout transform assigned to an element slice at line #{start_line + offset + 1}"
  end

  if section.any? { |line| line.include?("ame_stage_") }
    section_text = section.join
    section_text.scan(/^\s*U32\s+(\w+)\s*=.*;$/).flatten.each do |variable|
      next unless section_text.scan(/\b#{Regexp.escape(variable)}\b/).length == 1

      errors << "#{instruction}: staged-write pseudocode defines unused variable #{variable}"
    end
  end
end

{
  instructions_path => lines,
  programming_model_path => File.readlines(programming_model_path)
}.each do |path, document_lines|
  document_lines.each_with_index do |line, index|
    if line.match?(/\bm[a-z0-9]+\.1d(?:\.x)?\b/)
      errors << "#{File.basename(path)}: stale public .1d mnemonic at line #{index + 1}"
    end
    if path == instructions_path && line.include?("conceptual:")
      errors << "#{File.basename(path)}: non-executable conceptual NumPy example at line #{index + 1}"
    end
  end
end

abort "instruction semantic-shape errors:\n  #{errors.join("\n  ")}" unless errors.empty?

puts "checked #{headings.length} instructions: element bounds and writeback shapes are consistent"
