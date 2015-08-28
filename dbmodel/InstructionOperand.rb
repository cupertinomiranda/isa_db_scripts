class InstructionOperand
  include DataMapper::Resource

  property :id,				Serial
  property :number,			Integer

  belongs_to :instruction
  belongs_to :operand_type
  belongs_to :replacement_mask

  def parse_and_set_mask(opcode, letter, operands)
    next_letter = letter.next
    use_next_letter = (operands.select { |op| op =~ /^#{next_letter}/ }.count == 0) 
    use_next_letter = false if ['a','b','c','d','r'].index(letter.downcase)
    use_only_capital = true if ['a','c'].index(letter.downcase)

    mask = opcode.chars.map do |c|
      if(letter =~ /[^01]/)
	if(use_only_capital)
	  a = '1' if(c =~ /#{letter.upcase}/)
	else
	  a = '1' if(c =~ /#{letter}/)
	  a = '2' if(c =~ /#{letter.upcase}/)
	  a = '3' if(use_next_letter && c =~ /#{next_letter}/)
	  a = '4' if(use_next_letter && c =~ /#{next_letter.upcase}/)
	end
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

  def double_reg?

    dblMods = {
      "ldd" => [0, -1, -1],
      "std" => [0, -1, -1],
    }

    if (dblMods[instruction.mnemonic.downcase])
      lst = dblMods[instruction.mnemonic.downcase]
      return number == lst[0] || number == lst[1] || number == lst[2]
    end
  end

  def assembler_name
    nametype = operand_type.assembler_name
    nametype = "#{nametype}A" if ((nametype =~ /^Z$/) && number == 0)
    nametype = "#{nametype}B" if ((nametype =~ /^Z$/) && number == 1)
    nametype = "#{nametype}C" if ((nametype =~ /^Z$/) && number == 2)
    nametype = "#{nametype}D" if (double_reg? && operand_type.register? && ((nametype !~ /^Z/) && nametype !~ /^W[0-9]+/))

    if (operand_type.register?)
      nametype = "#{nametype}_S#{operand_type.size - bits_in_mask}" if (operand_type.size - bits_in_mask != 0)
    end

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
