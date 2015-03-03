class InstructionFlag
  include DataMapper::Resource

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
end
