class Instruction
  include DataMapper::Resource

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
end
