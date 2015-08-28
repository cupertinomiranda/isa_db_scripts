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
    opcode_size == 32 || opcode_size == 64
  end

  def clean_opcode(replace = 'x')
    opcode.split('').map{|c| c =~ /(0|1)/ ? c : replace}.join('')
  end

  def opcode_as_hex
    "0x%08X" % clean_opcode('0').to_i(2)
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
    cor0 = 1
    cor1 = 0
    if (self.class == "BRANCH" || self.class == "JUMP")
      cor1 = 13
      cor0 = -1
    end

    self.instruction_operands.map do |o|
      wgt += cor1 +  1 * cor0 if (o.operand_type.name =~ /[us]3/)
      wgt += cor1 +  2 * cor0 if (o.operand_type.name =~ /u5/)
      wgt += cor1 +  3 * cor0 if (o.operand_type.name =~ /u6/)
      wgt += cor1 +  4 * cor0 if (o.operand_type.name =~ /[us]7/)
      wgt += cor1 +  5 * cor0 if (o.operand_type.name =~ /[us]8/)
      wgt += cor1 +  6 * cor0 if (o.operand_type.name =~ /s9/)
      wgt += cor1 +  7 * cor0 if (o.operand_type.name =~ /[us]10/)
      wgt += cor1 +  8 * cor0 if (o.operand_type.name =~ /s11/)
      wgt += cor1 +  9 * cor0 if (o.operand_type.name =~ /s12/)
      wgt += cor1 + 10 * cor0 if (o.operand_type.name =~ /s13/)
      wgt += cor1 + 11 * cor0 if (o.operand_type.name =~ /s21/)
      wgt += cor1 + 12 * cor0 if (o.operand_type.name =~ /s25/)
      wgt += 20 if (o.operand_type.name =~ /limm/)
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

  def getsubclass
    return "NONE" if (self.subclass.to_s.empty?)
    return self.subclass.upcase
  end
end
