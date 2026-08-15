#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"

def active_asciidoc(text)
  in_comment_block = false
  text.each_line.each_with_object([]) do |line, active|
    if line.strip == "////"
      in_comment_block = !in_comment_block
      next
    end
    next if in_comment_block || line.lstrip.start_with?("//")

    active << line
  end.join
end

def include_closure(path, seen, errors)
  absolute = File.expand_path(path)
  return [] if seen.include?(absolute)

  seen << absolute
  unless File.file?(absolute)
    errors << "missing included file #{absolute}"
    return []
  end

  files = [absolute]
  active_asciidoc(File.read(absolute)).each_line do |line|
    match = line.match(/^\s*include::([^\[]+)\[[^\]]*\]/)
    next unless match

    files.concat(include_closure(File.expand_path(match[1], File.dirname(absolute)), seen, errors))
  end
  files
end

root = File.expand_path("..", __dir__)
instructions_path = File.join(root, "src", "instructions.adoc")
errors = []

instructions = active_asciidoc(File.read(instructions_path))
instruction_list = instructions.split("\n<<<\n", 2).first
categories = {}
listed_anchors = {}
current_category = nil
pending_name = nil
instruction_list.each_line do |line|
  current_category = Regexp.last_match(1) if line.match(/^(.+)::$/)
  if line.match(/^a\| `([^\s`]+)/)
    errors << "#{pending_name}: missing instruction-list target" if pending_name
    name = Regexp.last_match(1)
    errors << "#{name}: duplicate category entry" if categories.key?(name)
    categories[name] = current_category
    pending_name = name
  elsif pending_name && line.match(/^\| <<(ame:doc:inst:[^,>]+)(?:,[^>]*)?>>/)
    listed_anchors[pending_name] = Regexp.last_match(1)
    pending_name = nil
  end
end
errors << "#{pending_name}: missing instruction-list target" if pending_name

sections = instructions.scan(/^\[#(ame:doc:inst:[^\]]+)\]\n=== `([^`]+)`\n(.*?)(?=^<<<\s*$|\z)/m)
section_names = sections.map { |(_anchor, name, _section)| name }
section_anchors = sections.map { |(anchor, _name, _section)| anchor }

section_name_counts = section_names.each_with_object(Hash.new(0)) { |name, counts| counts[name] += 1 }
section_name_counts.each do |name, count|
  errors << "#{name}: expected one detailed instruction section, found #{count}" unless count == 1
end
section_anchor_counts = section_anchors.each_with_object(Hash.new(0)) { |anchor, counts| counts[anchor] += 1 }
section_anchor_counts.each do |anchor, count|
  errors << "#{anchor}: expected one detailed instruction anchor, found #{count}" unless count == 1
end

declared_count_text = instructions[/^AME defines \*(\d+)\* instructions\.$/, 1]
if declared_count_text.nil?
  errors << "instructions.adoc: missing declared instruction count"
else
  declared_count = declared_count_text.to_i
  unless declared_count == categories.length && declared_count == sections.length
    errors << "instructions.adoc: declared #{declared_count} instructions, " \
              "but the classification table has #{categories.length} and detailed sections have #{sections.length}"
  end
end

missing_sections = categories.keys.to_set - section_names.to_set
unlisted_sections = section_names.to_set - categories.keys.to_set
errors << "instruction-list entries without detailed sections: #{missing_sections.to_a.sort.join(', ')}" unless missing_sections.empty?
errors << "detailed sections absent from the instruction list: #{unlisted_sections.to_a.sort.join(', ')}" unless unlisted_sections.empty?

programming_model = active_asciidoc(File.read(File.join(root, "src", "programming_model.adoc")))
operand_class_table = programming_model[/\[\[ame-common-operand-classes\]\].*?^\|===\n(.*?)^\|===/m, 1]
if operand_class_table.nil?
  errors << "missing shared operand-class requirements table"
  operand_class_tokens = Set.new
else
  operand_class_tokens = operand_class_table.scan(/`([^`]+)`/).flatten.to_set
end

primary_contract = {
  "Resource Management" => "ame-common-state-access",
  "Datatype Management" => "ame-common-datatype-support",
  "Elementwise Arithmetic" => "ame-common-arithmetic",
  "Bitwise" => "ame-common-arithmetic",
  "Compare and Predication" => "ame-common-arithmetic",
  "Permutation" => "ame-common-structural",
  "Register move / data conversion" => "ame-common-register-groups",
  "Elementwise Math Functions" => "ame-common-arithmetic",
  "Memory" => "ame-common-memory",
  "State Management" => "ame-common-register-groups",
  "Matrix Multiply" => "ame-common-matmul",
  "Reduction" => "ame-common-structural"
}
data_scalar_categories = Set.new([
  "Elementwise Arithmetic",
  "Bitwise",
  "Compare and Predication",
  "Elementwise Math Functions"
])
control_scalar_names = Set.new(%w[
  mldexp.ew.x
  mldexpacc.ew.x
  msll.ew.x
  msra.ew.x
  msrl.ew.x
])

sections.each do |anchor, name, section|
  active_section = active_asciidoc(section)
  category = categories[name]
  errors << "#{name}: missing instruction-list category" unless category

  listed_anchor = listed_anchors[name]
  if listed_anchor.nil?
    errors << "#{name}: missing instruction-list target"
  elsif listed_anchor != anchor
    errors << "#{name}: instruction-list target #{listed_anchor} does not match detailed anchor #{anchor}"
  end

  %w[Synopsis Mnemonic Encoding Description Operation].each do |label|
    count = active_section.scan(/^#{label}::$/).length
    errors << "#{name}: expected one #{label} block, found #{count}" unless count == 1
  end
  unless active_section.match?(/^Operation::\n\+\n\[source\]\n----\n.+?\n----/m)
    errors << "#{name}: Operation is not a language-neutral source block"
  end

  description_raw = active_section[/^Description::\n(.*?)(?=^Operation::$)/m, 1]
  operation_raw = active_section[/^Operation::\n\+\n\[source\]\n----\n(.+?)\n----/m, 1]
  if description_raw&.match?(/^\s+.*`/)
    errors << "#{name}: indented description pseudocode contains literal inline-code delimiters"
  end
  if operation_raw&.match?(/`|\\|\^[^\n^]+\^|~[^\n~]+~/)
    errors << "#{name}: Operation source block contains AsciiDoc presentation markup"
  end

  if category
    contract = primary_contract[category]
    if contract.nil?
      errors << "#{name}: category #{category.inspect} has no common-contract mapping"
    elsif !active_section.match?(/<<#{Regexp.escape(contract)}(?:,[^>]*)?>>/)
      errors << "#{name}: missing required common contract #{contract}"
    end
  end

  data_scalar = name.end_with?(".ew.x") && data_scalar_categories.include?(category) &&
                !control_scalar_names.include?(name)
  if data_scalar && !active_section.match?(/<<ame-common-datatype-support(?:,[^>]*)?>>/)
    errors << "#{name}: data scalar does not reference the scalar datatype-conversion contract"
  end

  operand_class_exempt = ["Resource Management", "Datatype Management", "Memory"].include?(category) ||
                         name.match?(/^mmove(?:8|16|32|64)\./)
  class_family_name = name.end_with?(".ew.x") ? name.sub(/\.ew\.x\z/, ".ew") : name
  unless operand_class_exempt || operand_class_tokens.include?(name) || operand_class_tokens.include?(class_family_name)
    errors << "#{name}: no entry in the shared operand-class requirements table"
  end
end

root_document_path = File.join(root, "src", "riscv-spec.adoc")
required_root_includes = %w[
  contributors.adoc
  intro.adoc
  programming_model.adoc
  state.adoc
  datatypes.adoc
  parameters.adoc
  examples.adoc
  instructions.adoc
]
root_include_counts = Hash.new(0)
conditional_depth = 0
active_asciidoc(File.read(root_document_path)).each_line.with_index(1) do |line, line_number|
  if line.match?(/^\s*(?:ifdef|ifndef|ifeval)::/)
    conditional_depth += 1
    next
  end
  if line.match?(/^\s*endif::/)
    conditional_depth -= 1
    errors << "riscv-spec.adoc: unmatched endif at line #{line_number}" if conditional_depth.negative?
    conditional_depth = 0 if conditional_depth.negative?
    next
  end

  match = line.match(/^\s*include::([^\[]+)\[([^\]]*)\]/)
  next unless match

  include_name = match[1]
  next unless required_root_includes.include?(include_name)

  root_include_counts[include_name] += 1
  unless match[2].strip.empty?
    errors << "riscv-spec.adoc: required include #{include_name} must not select or filter content at line #{line_number}"
  end
  if conditional_depth.positive?
    errors << "riscv-spec.adoc: required include #{include_name} is conditional at line #{line_number}"
  end
end
errors << "riscv-spec.adoc: unterminated conditional directive" unless conditional_depth.zero?
required_root_includes.each do |include_name|
  count = root_include_counts[include_name]
  errors << "riscv-spec.adoc: required include #{include_name} must appear exactly once, found #{count}" unless count == 1

  include_path = File.join(root, "src", include_name)
  next unless File.file?(include_path)

  include_text = active_asciidoc(File.read(include_path))
  if include_text.match?(/^\s*(?:ifdef|ifndef|ifeval|else|endif)::/)
    errors << "#{include_name}: conditional directives are not permitted in required AME publication material"
  end
end

closure = include_closure(root_document_path, Set.new, errors)
archive_dir = ["legacy", %w[u db].join].join("-")
if closure.any? { |path| path.include?(File.join("formal", archive_dir)) }
  errors << "historical archive is reachable from the published document"
end
if closure.any? { |path| File.basename(path) == "functions.adoc" }
  errors << "retired src/functions.adoc remains in the published include closure"
end

active_published = closure.map { |path| active_asciidoc(File.read(path)) }.join("\n")
ame_doc_anchors = active_published.scan(/\[(?:#|\[)(ame:doc:[^\]\s]+)\]?\]/).flatten
ame_doc_anchor_counts = ame_doc_anchors.each_with_object(Hash.new(0)) { |anchor, counts| counts[anchor] += 1 }
ame_doc_anchor_counts.each do |anchor, count|
  errors << "published document contains #{count} active definitions of #{anchor}" if count > 1
end

ame_doc_references = active_published.scan(/<<(ame:doc:[^,>\s]+)(?:,[^>]*)?>>/).flatten.to_set
missing_targets = ame_doc_references - ame_doc_anchors.to_set
unless missing_targets.empty?
  errors << "published document references missing internal targets: #{missing_targets.to_a.sort.join(', ')}"
end

required_norm_anchors = %w[
  norm:ame_nsq_1d
  norm:ame_nsq_structural
  norm:ame_nsq_matmul
  norm:ame_register_group_overlap
  norm:ame_source_snapshot
  norm:ame_atomic_register_writeback
  norm:ame_register_exception_atomicity
  norm:ame_op_supported_contract
  norm:ame_op_supported_defined_result
  norm:ame_op_precondition
  norm:ame_op_result_width
  norm:ame_fp_special_values
]
required_norm_anchors.each do |anchor|
  count = active_published.scan(/^\[##{Regexp.escape(anchor)}\]/).length
  errors << "published document must contain exactly one active normative anchor #{anchor}, found #{count}" unless count == 1
end

abort "spec-structure validation failed:\n  #{errors.join("\n  ")}" unless errors.empty?

puts "checked #{sections.length} instruction pages: classification/detail sets and anchors agree, " \
     "required blocks, common contracts, and operand metadata are complete, " \
     "required publication includes are unconditional and exclude retired sources, " \
     "#{ame_doc_anchors.length} internal targets resolve uniquely, and " \
     "#{required_norm_anchors.length}/#{required_norm_anchors.length} normative anchors are published"
