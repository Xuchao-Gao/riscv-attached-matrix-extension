#!/usr/bin/env ruby
# frozen_string_literal: true

# Catch common formal-pseudocode mistakes that silently reduce an element
# access to one bit or discard all but the last element result.

instructions_path = File.join(__dir__, "..", "src", "instructions.adoc")
programming_model_path = File.join(__dir__, "..", "src", "programming_model.adoc")
functions_path = File.join(__dir__, "..", "src", "functions.adoc")
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

  operation_label = section.index { |line| line.strip == "Operation::" }
  operation = nil
  if operation_label
    # Collect all contiguous source blocks under Operation::
    # (separated only by blank lines or list-continuation "+")
    operation_lines = []
    cursor = operation_label
    in_block = false
    while cursor < section.length
      line = section[cursor]
      if !in_block
        if line.strip == "----"
          in_block = true
        elsif line.strip.empty? || line.strip == "+"
          # skip blank lines and list continuations between blocks
        elsif line.strip.start_with?("[source") || line.strip.start_with?("[subs")
          # skip block attributes
        else
          # non-blank, non-attribute, non-delimiter line => end of Operation
          break unless operation_lines.empty?
        end
      else
        if line.strip == "----"
          in_block = false
        else
          operation_lines << line
        end
      end
      cursor += 1
    end
    operation = operation_lines unless operation_lines.empty?
  end

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

  if operation
    section_text = section.join
    operation_text = operation.join

    scalar_data_instructions = %w[
      mabsdiff.ew.x madd.ew.x mand.ew.x mandnot.ew.x mcmpge.ew.x mcmplt.ew.x
      mhdiff.ew.x mlog2sub.ew.x mmax.ew.x mmean.ew.x mmin.ew.x mmul.ew.x
      mmulacc.ew.x mmulaccneg.ew.x mmuladd.ew.x mmulneg.ew.x mmulsub.ew.x
      mor.ew.x mornot.ew.x msub.ew.x msublog2.ew.x mxor.ew.x
    ]
    if scalar_data_instructions.include?(instruction)
      errors << "#{instruction}: data-scalar operation must use ame_scalar_op_supported" unless operation_text.include?("ame_scalar_op_supported")
      errors << "#{instruction}: data-scalar value must use ame_scalar_data_value" unless operation_text.include?("ame_scalar_data_value")
    end

    fixed_control_instructions = %w[
      mldexp.ew.x mldexpacc.ew.x mrowshift.ew.x mcolshift.ew.x
      msll.ew.x msra.ew.x msrl.ew.x mpack.ew.x munpack.ew.x
    ]
    if fixed_control_instructions.include?(instruction) && operation_text.include?("ame_scalar_")
      errors << "#{instruction}: fixed control scalar must not use scalar datatype CSR helpers"
    end

    idl_type = /(?:Bool|XReg|U(?:32|64)|S(?:32|64)|Integer|Bits<[^>]+>)/
    declarations = section_text.scan(/\b#{idl_type}\s+(\w+)\s*(?==|;)/).flatten

    # Derived datatype, value, and element-address variables are local
    # implementation details, rather than architectural operands or constants.
    # Requiring a declaration for every use catches mechanically truncated
    # read-modify-write sequences while avoiding false positives for decoded
    # operands such as md, ms1, and xs1.
    derived_suffix = /(?:regno|hi|lo|hi_idx|lo_idx|dtype|element_size|nregs|elements_per_reg|value|current|element_value)/
    derived_variables = operation_text.scan(/\b([A-Za-z_]\w*_#{derived_suffix})\b/).flatten.uniq
    derived_variables -= %w[ame_scalar_data_value]
    (derived_variables - declarations).each do |variable|
      errors << "#{instruction}: Operation block uses undefined variable #{variable}"
    end

    # Check every IDL local type, not just U32.  This catches dead value
    # snapshots such as Bits<...> dest_current as well as dead index arithmetic.
    operation_text.scan(/\b#{idl_type}\s+(\w+)\s*(?==|;)/).flatten.uniq.each do |variable|
      next unless operation_text.scan(/\b#{Regexp.escape(variable)}\b/).length == 1

      errors << "#{instruction}: Operation block defines unused variable #{variable}"
    end

    if instruction.match?(/^m(?:prefix|reduce)(?:add|max)\.(?:col|row)$/) &&
       operation_text.match?(/Bits<AME_MAX_DTYPE_SIZE>\s+(?:running|col_result|row_result)\s*=\s*0;/)
      errors << "#{instruction}: prefix/reduction fold must seed from the first source element, not raw zero"
    end

    if operation_text.match?(/sum\s*=\s*sum\s+pass:\[\+\].*AmeOperation::MM/)
      errors << "#{instruction}: matrix products must use ame_matmul_accumulate, not raw bit-vector addition"
    end

    conversion_requirements = {
      "mconv.ew" => %w[ame_check_m_group ame_read_m_element ame_stage_m_element_write],
      "mpack.ew.x" => %w[ame_check_m_group ame_read_m_element],
      "munpack.ew.x" => %w[ame_check_m_group ame_stage_m_element_write]
    }
    Array(conversion_requirements[instruction]).each do |helper|
      errors << "#{instruction}: wide-safe conversion path must call #{helper}" unless operation_text.include?(helper)
    end
  end
end

functions_text = File.read(functions_path)
%w[ame_check_m_index ame_check_m_group ame_read_m_element ame_matmul_accumulate].each do |helper|
  errors << "functions.adoc: missing common #{helper} contract" unless functions_text.include?("[#ame:doc:func:#{helper}]")
end

programming_model_text = File.read(programming_model_path)
%w[ame_nsq_1d ame_nsq_structural ame_nsq_matmul].each do |rule|
  errors << "programming_model.adoc: missing normative #{rule} rule" unless programming_model_text.include?("[#norm:#{rule}]")
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

puts "checked #{headings.length} instructions: element bounds, local identifiers, and writeback shapes are consistent"
