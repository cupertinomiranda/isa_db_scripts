class InstructionOperand
  include DataMapper::Resource

    property :id, 				Serial
	property :number,			Integer

	belongs_to :instruction
	belongs_to :operand_type	
end