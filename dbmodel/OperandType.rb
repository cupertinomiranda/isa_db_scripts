class OperandType
  include DataMapper::Resource

  property :id, 				Serial
  property :name,				String

  has n, :instruction_operands


  def linker_relocatable
    return true if name =~ /limm/
    return true if name =~ /^u[0-9]+/
    return true if name =~ /^s[0-9]+/
    #return true if name =~ /^w[0-9]+/

    return false
  end

  def size
    return 32           if(name =~ /^limm~/)
    return $1.to_i	if(name =~ /(\d+)$/)
    return 6 if (register?)
    return 0
  end
  def size_known?
    return (size != 0)
  end

  def register?
    return !linker_relocatable
  end

  def limm?
    return true if name =~ /limm/
  end

  def simm?
    return !register? && !limm?
  end
  def signed?
    return true if (name =~ /^s[0-9]+/)
    return false
  end

  def identifier
    "#{name}_"
  end
  def extended_name
    return "#{$1}imm#{$2}" if name =~ /([us])([1-9][0-9]*)/
    return name
  end

  def replacement_masks
    instruction_operands.map { |iop| iop.replacement_mask }.uniq { |rp| rp.reloc_mask }
  end

  #Create the unique identifier for the assembler name
  def assembler_name
    return "UIMM#{$1}" if (name =~ /u([0-9]+)/)
    return "SIMM#{$1}" if (name =~ /s([0-9]+)/)
    return "BLINK"     if (name.downcase == "blink")
    return "R#{$1.upcase}" if(name =~ /([abch])/)
    return "Z" if(name =~ /^0$/)
    return name.upcase # ILINKx, SP, GP, PCL
  end

  def test_op_name
    return "0" if (name =~ /limm/)
    return "0" if (name =~ /u([0-9]+)/)
    return "0" if (name =~ /s([0-9]+)/)
    return "BLINK"     if (name.downcase == "blink")
    return "r0" if(name =~ /([a])/)
    return "r1" if(name =~ /([b])/)
    return "r2" if(name =~ /([c])/)
    return "r3" if(name =~ /([h])/)
    return "0" if(name =~ /^0$/)
    return name.downcase # ILINKx, SP, GP, PCL
  end

  #def self.operand_type_for_iop(op_name, iop)
  #  tmp = OperandType.new(name: op_name)

  #  # Decide on operand_type name based on mask and other features
  #  op_name = tmp.assembler_name
  #  op_name = "#{op_name}A" if ((op_name =~ /^Z$/) && iop.number == 0)
  #  op_name = "#{op_name}B" if ((op_name =~ /^Z$/) && iop.number == 1)
  #  op_name = "#{op_name}C" if ((op_name =~ /^Z$/) && iop.number == 2)
  #  op_name = "#{op_name}D" if (iop.double_reg? && tmp.register? && ((op_name !~ /^Z/) && op_name !~ /^W[0-9]+/))
  #  
  #  if (tmp.simm?)
  #    #fbmsk = bit_replacement_mask.first_bit_with("1")
  #    fbmsk = iop.instruction.opcode.index(/[su]/)
  #    op_name = "#{op_name}_A16" if (iop.bits_in_mask == (tmp.size - 1))
  #    op_name = "#{op_name}_A32" if (iop.bits_in_mask == (tmp.size - 2))
  #    op_name = "#{op_name}_AXX" if (iop.bits_in_mask < (tmp.size - 2))
  #    op_name = "#{op_name}_#{fbmsk}"
  #  end
  #  
  #  op_name = "#{op_name}_S" if (!iop.instruction.long?)

  #  operand_type = OperandType.first(name: op_name)
  #  if(operand_type.nil?)
  #    operand_type = OperandType.create({
  #      name: op_name
  #    })
  #  end
  #  return operand_type
  #end
end
