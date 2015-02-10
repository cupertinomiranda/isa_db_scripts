class InstructionOperand
  include DataMapper::Resource

  property :id, 				Serial
	property :number,			Integer

	property :replacement_mask, String

	belongs_to :instruction
	belongs_to :operand_type	

	def set_mask(opcode, letter) 
		self.replacement_mask = 
		  opcode.chars
			  		.map { |c| (c =~ /#{letter}/ || c =~ /#{letter.upcase}/) ? c : '0' }
				  	.join('')
	end

	def bits_in_mask 
		replacement_mask.chars.select { |c| c !~ /0/ }.count
	end
	
end
