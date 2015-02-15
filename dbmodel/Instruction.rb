class Instruction
  include DataMapper::Resource
  include Comparable

  property :id,         Serial    # An auto-increment integer key
  property :mnemonic,   String    # A varchar type string, for short strings
  property :opcode,     String    # A text block, for longer string data.
  property :class,      String    # A text block, for longer string data.
  property :subclass,   String    # A text block, for longer string data.

  #property :flagZ, 		Boolean
  #property :flagN, 		Boolean
  #property :flagC, 		Boolean
  #property :flagV, 		Boolean
  #property :flagS, 		Boolean

  has n, :instruction_operands
  has n, :instruction_flags, :through => Resource

  has n, :conditional_cpu_instruction_relations

  def opcode_size
    self.opcode.length
  end

  def long?
    opcode_size == 32
  end

  def mask
    opcode.gsub(/[01]/, '1').gsub(/[^1]/, '0')
  end

  def fixed_opcode
    i = -1
    mask_array = mask.chars
    ret = opcode.split(//).map { |c| mask_array[i += 1] =~ /1/ ? c : '0' }.join('')
    return ret
  end

  def usage_example
    ret = self.mnemonic
  end

  #compute the weight for each instruction. The GAS requires a particular 
  #order based on this wight (i.e. shorter immediates first, limm is last)
  def weight 
    wgt = 0
    self.instruction_operands.map do |o|
      wgt += 1 if (o.operand_type.name =~ /[us]3/)
      wgt += 2 if (o.operand_type.name =~ /u5/)
      wgt += 3 if (o.operand_type.name =~ /u6/)
      wgt += 4 if (o.operand_type.name =~ /[us]7/)
      wgt += 5 if (o.operand_type.name =~ /[us]8/)
      wgt += 6 if (o.operand_type.name =~ /s9/)
      wgt += 7 if (o.operand_type.name =~ /[us]10/)
      wgt += 8 if (o.operand_type.name =~ /s11/)
      wgt += 9 if (o.operand_type.name =~ /s12/)
      wgt +=10 if (o.operand_type.name =~ /s13/)
      wgt +=11 if (o.operand_type.name =~ /s21/)
      wgt +=12 if (o.operand_type.name =~ /s25/)
      wgt +=20 if (o.operand_type.name =~ /limm/)
    end

    return wgt
  end

  #Make this class comparable. To be used by sort
  def <=>(anOther)
    ret = mnemonic <=> anOther.mnemonic
    return ret if (ret != 0)
    return -1 if (self.weight < anOther.weight)
    return 1 if (self.weight > anOther.weight)
    return 0   
  end
end
