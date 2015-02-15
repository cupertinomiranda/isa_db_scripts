class InstructionFlag
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :type, 			String
  property :mnemonic_patch, String

  has n, :instructions, :through => Resource


  def assembler_name
  	nme = mnemonic_patch.upcase.sub('<', "")
	nme = nme.sub('.', "")
    nme = nme.sub('>', "")
  	return "C_#{nme}"
  end
end
