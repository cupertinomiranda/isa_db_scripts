class InstructionFlag
  include DataMapper::Resource
  include Comparable

  property :id,         Serial    # An auto-increment integer key
  property :type, 	String
  property :mnemonic_patch, String

  has n, :instructions, :through => Resource

  def assembler_name
    mne = mnemonic_patch.sub('<', "")
    mne = mne.sub('.', "")
    mne = mne.sub('>', "")
    mne = "Xhard" if (mne == "X")
    mne = "Fhard" if (mne == "F")
    mne = "Dhard" if (mne == "D")
    return "C_#{mne.upcase}"
  end

  #Make this class comparable. To be used by sort
  def <=>(anOther)
    return -1 if ( self.assembler_name =~ /C_ZZ/)
    return 1 if ( anOther.assembler_name =~ /C_ZZ/)
    return 0
  end
end
