class BitReplacement < Enumerator
  @@container = []
  attr_reader :operand_type, :replacement_mask

  def self.each
    @@container.each { |a| yield(a) }
  end

  def self.find_for_instruction_operand(inst_op)
    return @@container.select { |v| v.operand_type == inst_op.operand_type && v.replacement_mask == inst_op.replacement_mask }[0]
  end

  def initialize(opt, mask)
    @operand_type = opt
    @replacement_mask = mask

    @@container <<= self
  end

  def ignore_bits
    return 0 unless operand_type.size_known?
    return operand_type.size - replacement_mask.number_of_bits
  end

  def name
    operand_type.assembler_name
  end

  def first_bit_with(letter)
    count = 0
    mask = replacement_mask.mask.split('')
    mask.each do |v|
      if(v =~ /#{letter}/)
	return count
      end
      count += 1
    end
    return nil
  end
  def size_with(letter)
    mask = replacement_mask.mask.split('')
    size = 0
    mask.each do |v|
      if(v =~ /#{letter}/)
	size += 1
	    end
    end
    return size
  end

  def replacements
    mask = replacement_mask.mask.split('')
#    print mask
    symbol_used = ignore_bits
#    puts "BLA"
    [1,2,3,4].each do |i|
      loc = first_bit_with("#{i}")
      size = size_with("#{i}")

      if(!loc.nil?)
	opcode_size = mask.count
	repl_mask = "0x%04x" % ((2**size) - 1)
	loc = opcode_size - loc - size

	yield(symbol_used, loc, repl_mask)

	symbol_used += size
      end
    end
  end
end
