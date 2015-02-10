class ConditionalCpuInstructionRelation
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :condition, 	String

	belongs_to :instruction, :key => true
	belongs_to :cpu_version, :key => true
end
