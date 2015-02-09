class Instruction
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :mnemonic,   String    # A varchar type string, for short strings
  property :opcode,     String    # A text block, for longer string data.
  property :class,      String    # A text block, for longer string data.
  property :subclass,   String    # A text block, for longer string data.

  property :flagZ, 		Boolean
  property :flagN, 		Boolean
  property :flagC, 		Boolean
  property :flagV, 		Boolean
  property :flagS, 		Boolean

	has n, :instruction_operands

  def opcode_size
    self.opcode.length
  end

	def mask
		opcode.gsub(/[01]/, '1').gsub(/[^1]/, '0')
	end

	def fixed_opcode
		# opcode.to_i(2) & mask.to_i(2)
		opcode.to_i(2) & mask.to_i(2)
	end

	def usage_example
		ret = self.mnemonic
	end
end
