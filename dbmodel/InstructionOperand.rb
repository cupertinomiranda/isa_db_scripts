class InstructionOperand
  include DataMapper::Resource

  property :id, 				Serial
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
		replacement_mask.chars.select { |c| c !~ /0/ }.count
	end
	
end
