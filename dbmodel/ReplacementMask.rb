class ReplacementMask
  include DataMapper::Resource

  property :id, 				Serial
	property :mask,			  String
	
	has n, :instruction_operands

	def number_of_bits
		mask.split('').select { |b| b != '0' }.count
	end

	
end
