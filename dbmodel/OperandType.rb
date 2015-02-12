class OperandType
  include DataMapper::Resource

	property :id, 				Serial
	property :name,				String
	
	has n, :instruction_operands

	def linker_relocatable 
		return true if name =~ /limm/
		return true if name =~ /^u[0-9]/
		return true if name =~ /^s[0-9]/

		return false
	end

	def size
		return $1.to_i	if(name =~ /([1-9][0-9]+)$/)
		return nil
	end
	def size_known?
		return (size != nil)
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
end
