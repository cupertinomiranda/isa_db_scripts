class InstructionOperand
  include DataMapper::Resource

  property :id,				Serial
  property :number,			Integer

  belongs_to :instruction
  belongs_to :operand_type
  belongs_to :replacement_mask

  def set_mask(opcode, letter, operands)
    next_letter = letter.next
    use_next_letter = (operands.select { |op| op =~ /^#{next_letter}/ }.count == 0)

    mask = opcode.chars.map do |c|
      if(letter =~ /[^01]/)
	a = '1' if(c =~ /#{letter}/)
	a = '2' if(c =~ /#{letter.upcase}/)
	a = '3' if(use_next_letter && c =~ /#{next_letter}/)
	a = '4' if(use_next_letter && c =~ /#{next_letter.upcase}/)
      end
      a || '0'
    end
    mask = mask.join('')

    repl_mask = ReplacementMask.first(mask: mask)
    repl_mask = ReplacementMask.create(mask: mask) if (repl_mask.nil?)

    self.replacement_mask = repl_mask
  end

  def bits_in_mask
    replacement_mask.number_of_bits
  end

  def bit_replacement_mask
    BitReplacement.find_for_instruction_operand(self)
  end

  def assembler_name
    nametype = operand_type.assembler_name
    nametype = "#{nametype}A" if ((nametype =~ /^Z$/) && number == 0)
    nametype = "#{nametype}B" if ((nametype =~ /^Z$/) && number == 1)
    nametype = "#{nametype}C" if ((nametype =~ /^Z$/) && number == 2)

    if (operand_type.simm?)
      #fbmsk = bit_replacement_mask.first_bit_with("1")
      fbmsk = instruction.opcode.index(/[su]/)
      nametype = "#{nametype}_A16" if (bits_in_mask == (operand_type.size - 1))
      nametype = "#{nametype}_A32" if (bits_in_mask == (operand_type.size - 2))
      nametype = "#{nametype}_AXX" if (bits_in_mask < (operand_type.size - 2))
      nametype = "#{nametype}_#{fbmsk}"
    end

    nametype = "#{nametype}_S" if (!instruction.long?)
    return nametype
  end

end
