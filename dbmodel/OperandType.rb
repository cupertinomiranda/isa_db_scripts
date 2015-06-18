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
    instruction_operands.map { |iop| iop.replacement_mask }.uniq
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

end
