class CpuVersion
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :name, 			String

	has n, :conditional_cpu_instruction_relations

end
