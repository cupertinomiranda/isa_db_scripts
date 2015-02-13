class InstructionFlag
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :type, 			String
  property :mnemonic_patch, String

  has n, :instructions, :through => Resource
end
