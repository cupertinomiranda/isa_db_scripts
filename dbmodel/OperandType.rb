class OperandType
  include DataMapper::Resource

	property :id, 				Serial
	property :name,				String
	
	has n, :instruction_operands
end