# frozen_string_literal: true

require "json"
require "set"

module AmeEncoding
  class ValidationError < StandardError; end

  # One normalized encoding model shared by validation and generated artifacts.
  class InstructionSet
    OPCODE_MASK = 0x0000007f
    DEST_MASK = 0x00000f80
    FUNCT3_MASK = 0x00007000
    SRC1_MASK = 0x000f8000
    SRC2_MASK = 0x01f00000
    FUNCT7_MASK = 0xfe000000
    SKELETON_MASK = OPCODE_MASK | FUNCT3_MASK | FUNCT7_MASK

    attr_reader :root, :entries, :attributes, :attribute_text, :banks,
                :fixed_members, :opcode, :funct3, :r3_allocated_funct7,
                :r3_reserved_funct7

    def initialize(root:)
      @root = File.expand_path(root)
      @used_attributes = Set.new
      load_policy!
      load_entries!
    end

    def validate!
      unused = @attributes.keys - @used_attributes.to_a
      check(unused.empty?, "unused allocation attributes: #{unused.join(', ')}")

      @entries.each do |entry|
        check((entry[:mask] & SKELETON_MASK) == SKELETON_MASK,
              "#{entry[:name]} does not fix the funct7/funct3/opcode skeleton")
        check((entry[:value] & OPCODE_MASK) == @opcode,
              "#{entry[:name]} does not use opcode 0x#{@opcode.to_s(16)}")
        check(entry[:funct3] == @funct3,
              "#{entry[:name]} uses funct3=#{entry[:funct3]}, expected #{@funct3}")
      end

      validate_banks!
      validate_fixed_members!
      validate_mnemonics!
      validate_dense_selectors!
      validate_overlaps!
      self
    end

    def bank(id)
      @banks_by_id.fetch(id)
    end

    def bank_entries(record)
      @entries.select { |entry| entry[:format] == record[:format] && entry[:funct7] == record[:funct7] }
    end

    def bank_fixed_entries(record)
      names = @fixed_members.select { |member| member[:bank] == record[:id] }.map { |member| member[:name] }
      @entries.select { |entry| names.include?(entry[:name]) }
    end

    def used_selectors(record)
      bank_entries(record).map { |entry| entry[:extension] }.sort
    end

    def selector_capacity(record)
      1 << record[:selector_bits]
    end

    def free_selectors(record)
      (0...selector_capacity(record)).to_a - used_selectors(record) - record[:reserved_selectors]
    end

    def allocated_funct7
      (@r3_allocated_funct7 + @banks.map { |record| record[:funct7] }).uniq.sort
    end

    def free_funct7
      (0x00..0x7f).to_a - allocated_funct7
    end

    def overlaps
      @entries.combination(2).select do |left, right|
        common = left[:mask] & right[:mask]
        ((left[:value] ^ right[:value]) & common).zero?
      end
    end

    def format_counts
      @entries.group_by { |entry| entry[:format] }.transform_values(&:length)
    end

    private

    def check(condition, message)
      raise ValidationError, message unless condition
    end

    def int(value, label)
      value.is_a?(Integer) ? value : Integer(value, 0)
    rescue ArgumentError, TypeError
      raise ValidationError, "#{label} is not an integer: #{value.inspect}"
    end

    def expand_ranges(ranges, label)
      ranges.flat_map.with_index do |pair, index|
        check(pair.is_a?(Array) && pair.length == 2, "#{label}[#{index}] is not a range")
        first = int(pair[0], label)
        last = int(pair[1], label)
        check(first <= last, "#{label}[#{index}] is reversed")
        (first..last).to_a
      end
    end

    def load_policy!
      raw = JSON.parse(File.read(File.join(@root, "scripts", "data", "instruction-encoding-allocation.json")))
      check(raw["schema_version"] == 1, "unsupported allocation schema version")
      @attribute_text = raw.fetch("attributes")
      @attributes = @attribute_text.transform_values { |value| int(value, "allocation attribute") }
      @opcode = int(raw.fetch("opcode"), "opcode")
      @funct3 = int(raw.fetch("funct3"), "funct3")

      r3 = raw.fetch("r3")
      @r3_allocated_funct7 = expand_ranges(r3.fetch("allocated_funct7_ranges"), "R3 allocation")
      @r3_reserved_funct7 = r3.fetch("reserved_funct7").map { |value| int(value, "R3 reservation") }
      @banks = raw.fetch("banks").map do |record|
        attribute = record.fetch("funct7_attribute")
        {
          id: record.fetch("id"), label: record.fetch("label"), format: record.fetch("format"),
          funct7_attribute: attribute, funct7: @attributes.fetch(attribute),
          selector_name: record.fetch("selector_name"), selector_bits: int(record.fetch("selector_bits"), "selector width"),
          reserved_selectors: record.fetch("reserved_selectors").map { |value| int(value, "reserved selector") }
        }
      end
      @banks_by_id = @banks.each_with_object({}) do |record, result|
        check(!result.key?(record[:id]), "duplicate bank #{record[:id]}")
        result[record[:id]] = record
      end
      @fixed_members = raw.fetch("fixed_members").map do |record|
        {
          name: record.fetch("name"), bank: record.fetch("bank"),
          selector: int(record.fetch("selector"), "fixed selector"),
          match: int(record.fetch("match"), "fixed match")
        }
      end
      validate_policy!
    rescue JSON::ParserError => error
      raise ValidationError, "invalid allocation JSON: #{error.message}"
    rescue KeyError => error
      raise ValidationError, "allocation policy is missing #{error.key.inspect}"
    end

    def validate_policy!
      check((0...128).cover?(@opcode) && (0...8).cover?(@funct3), "opcode or funct3 is out of range")
      check(@attributes["ame-enc-funct3"] == @funct3, "funct3 attribute disagrees with policy")
      check(@r3_allocated_funct7.uniq.length == @r3_allocated_funct7.length &&
            @r3_allocated_funct7.all? { |value| (0...128).cover?(value) },
            "R3 ranges overlap or exceed funct7")
      check(@r3_reserved_funct7.uniq.length == @r3_reserved_funct7.length &&
            (@r3_reserved_funct7 - @r3_allocated_funct7).empty?,
            "R3 reservations are duplicated or outside the allocation")

      @banks.each do |record|
        expected_bits = { "R2" => 5, "R1" => 10 }[record[:format]]
        check(record[:selector_bits] == expected_bits, "#{record[:id]} has the wrong selector width")
        capacity = selector_capacity(record)
        reserved = record[:reserved_selectors]
        check(reserved.uniq.length == reserved.length && reserved.all? { |value| (0...capacity).cover?(value) },
              "#{record[:id]} has invalid reserved selectors")
      end
      bank_values = @banks.map { |record| record[:funct7] }
      check(bank_values.uniq.length == bank_values.length &&
            bank_values.all? { |value| (0...128).cover?(value) } &&
            (bank_values & @r3_allocated_funct7).empty?,
            "R2/R1 banks overlap or exceed funct7")

      names = @fixed_members.map { |member| member[:name] }
      slots = @fixed_members.map { |member| [member[:bank], member[:selector]] }
      check(names.uniq.length == names.length && slots.uniq.length == slots.length, "duplicate fixed-member allocation")
      @fixed_members.each do |member|
        record = @banks_by_id[member[:bank]]
        check(record && record[:reserved_selectors].include?(member[:selector]),
              "#{member[:name]} does not occupy a reserved selector")
        check((0..0xffffffff).cover?(member[:match]), "#{member[:name]} match exceeds 32 bits")
      end
    end

    def load_entries!
      source = File.read(File.join(@root, "src", "instructions.adoc"))
      @entries = []
      names = Set.new
      source.scan(/^=== `([^`]+)`\n(.*?)(?=^=== `|\z)/m) do |name, section|
        check(names.add?(name), "duplicate instruction section #{name}")
        diagrams = section.lines.select { |line| line.start_with?('{"reg":') }
        diagram = diagrams.first
        unallocated = section.include?("This specification does not assign an instruction encoding.")
        check(!(diagram && unallocated), "#{name} is both encoded and marked unallocated")
        next if unallocated
        check(diagrams.length == 1, "#{name} has #{diagrams.length} WaveDrom encodings, expected one")
        mnemonic = section[/^Mnemonic::\n`([^`]+)`/, 1]
        check(mnemonic, "#{name} has no mnemonic")
        @entries << parse_entry(name, mnemonic, diagram)
      end
    end

    def parse_entry(name, mnemonic, diagram)
      position = 0
      mask = 0
      value = 0
      fields = []
      pattern = /"bits"\s*:\s*(\d+)\s*,\s*"name"\s*:\s*(\{[^}]+\}|"[^"]+"|-?(?:0x[0-9a-f]+|\d+))/i
      diagram.scan(pattern) do |width_text, token|
        width = int(width_text, "#{name} field width")
        check(width.positive?, "#{name} field width is not positive")
        lo = position
        hi = position + width - 1
        if token.start_with?('"')
          fields << { kind: :operand, name: token[1...-1], width: width, hi: hi, lo: lo }
        else
          attribute = token[/\A\{([^}]+)\}\z/, 1]
          if attribute
            check(@attributes.key?(attribute), "#{name} uses unknown attribute #{attribute}")
            @used_attributes << attribute
          end
          field_value = attribute ? @attributes[attribute] : int(token, "#{name} field")
          check(field_value >= 0 && field_value < (1 << width),
                "#{name} value #{field_value} does not fit in #{width} bits")
          field_mask = ((1 << width) - 1) << lo
          mask |= field_mask
          value |= field_value << lo
          fields << { kind: :fixed, value: field_value, attribute: attribute, width: width, hi: hi, lo: lo }
        end
        position += width
      end
      check(position == 32, "#{name} encoding is #{position} bits, expected 32")

      dest_fixed = (mask & DEST_MASK) == DEST_MASK
      src1_fixed = (mask & SRC1_MASK) == SRC1_MASK
      src2_fixed = (mask & SRC2_MASK) == SRC2_MASK
      format = if !src2_fixed
                 check(!src1_fixed, "#{name} uses src2 but fixes src1")
                 "R3"
               elsif !src1_fixed
                 "R2"
               elsif !dest_fixed
                 "R1"
               else
                 "Fixed"
               end
      extension = format == "R2" ? (value >> 20) & 0x1f : (format == "R1" ? (value >> 15) & 0x3ff : nil)
      {
        name: name, mnemonic: mnemonic, fields: fields, mask: mask, value: value,
        format: format, funct7: (value >> 25) & 0x7f,
        funct3: (value >> 12) & 0x7, extension: extension
      }
    end

    def validate_banks!
      expected = {
        "R3" => @r3_allocated_funct7 - @r3_reserved_funct7,
        "R2" => @banks.select { |record| record[:format] == "R2" }.map { |record| record[:funct7] },
        "R1" => @banks.select { |record| record[:format] == "R1" }.map { |record| record[:funct7] },
        "Fixed" => @fixed_members.map { |member| bank(member[:bank])[:funct7] }
      }
      expected.each do |format, values|
        actual = @entries.select { |entry| entry[:format] == format }.map { |entry| entry[:funct7] }.uniq.sort
        check(actual == values.uniq.sort, "#{format} funct7 banks #{actual.inspect}, expected #{values.uniq.sort.inspect}")
      end
    end

    def validate_fixed_members!
      actual = @entries.select { |entry| entry[:format] == "Fixed" }.map { |entry| entry[:name] }.sort
      expected = @fixed_members.map { |member| member[:name] }.sort
      check(actual == expected, "fixed encodings #{actual.inspect}, expected #{expected.inspect}")
      @fixed_members.each do |member|
        entry = @entries.find { |candidate| candidate[:name] == member[:name] }
        record = bank(member[:bank])
        shift = record[:format] == "R2" ? 20 : 15
        selector = (entry[:value] >> shift) & ((1 << record[:selector_bits]) - 1)
        check(entry[:mask] == 0xffffffff && entry[:value] == member[:match] &&
              entry[:funct7] == record[:funct7] && selector == member[:selector],
              "#{member[:name]} does not match its fixed allocation")
      end
    end

    def validate_mnemonics!
      @entries.each do |entry|
        mnemonic_name, operand_text = entry[:mnemonic].split(/\s+/, 2)
        operands = operand_text.to_s.split(",").map do |operand|
          operand.strip.sub(/\A\(([^)]+)\)\z/, '\\1')
        end.reject(&:empty?)
        fields = entry[:fields].select { |field| field[:kind] == :operand }.map { |field| field[:name] }
        check(mnemonic_name == entry[:name] && operands == fields,
              "#{entry[:name]} mnemonic operands #{operands.inspect} do not match diagram #{fields.inspect}")
      end
    end

    def validate_dense_selectors!
      @banks.each do |record|
        values = used_selectors(record)
        available = (0...selector_capacity(record)).to_a - record[:reserved_selectors]
        check(values.length <= available.length && values == available.take(values.length),
              "#{record[:id]} has sparse or over-capacity selectors: #{values.join(',')}")
      end
      @banks.group_by { |record| record[:format] }.each do |format, family|
        family.each_with_index do |record, index|
          later_used = family[(index + 1)..-1].to_a.any? { |later| !used_selectors(later).empty? }
          next unless later_used
          available = selector_capacity(record) - record[:reserved_selectors].length
          check(used_selectors(record).length == available,
                "#{format} opens a later bank before filling #{record[:id]}")
        end
      end
    end

    def validate_overlaps!
      return if overlaps.empty?

      details = overlaps.map do |left, right|
        kind = left[:mask] == right[:mask] && left[:value] == right[:value] ? "duplicate" : "overlap"
        "#{kind}: #{left[:name]}/#{right[:name]}"
      end
      raise ValidationError, "encoding collisions: #{details.join(', ')}"
    end
  end
end
