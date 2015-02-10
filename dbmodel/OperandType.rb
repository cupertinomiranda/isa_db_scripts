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
		return $1	if(name =~ /[1-9][0-9]+$/)
		return nil
	end
end
