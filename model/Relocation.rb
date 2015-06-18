class Relocation < Enumerator
  @@container = []
  attr_reader :name, :type, :value, :calc, :complain_overflow

  def self.each
    @@container.each { |a| yield(a) }
  end

  def self.all
    @@container
  end

  def initialize(string)
    data = string.split(/[\s\t]+/)
    if(data.count >= 5)
      @name = data[0]
      @value = data[1].to_i(16)
      @type = data[2]
      @complain_overflow = data[3]
      @calc = RelocationCalcParser.new().parse(data[4])
      @info = data[5] # Only informational no real use

      @@container <<= self
    end

    #puts "Reloc #{name} => #{value}"
  end

  def replacement_mask 
    ret = ReplacementMask.first(name: @type)
    raise "Relocation #{self.name} has no replacement mask" if ret.nil?
    #puts "name = #{@type} -> mask = #{ret.mask}"
    return ret
  end
  def type_compatible?(t)
    return false
  end
  def type_name 
    return @type
  end
end


# Generic
#Relocation.new("R_ARC_NONE          0x0   none      bitfield    none")
Relocation.new("R_ARC_8             0x1   bits8     bitfield    S+A")
Relocation.new("R_ARC_16            0x2   bits16    bitfield    S+A")
Relocation.new("R_ARC_24            0x3   bits24    bitfield    S+A")
Relocation.new("R_ARC_32            0x4   word32    bitfield    S+A")

# Unsupported
Relocation.new("R_ARC_N8            0x8   bits8     bitfield    S-A")
Relocation.new("R_ARC_N16           0x9   bits16    bitfield    S-A")
Relocation.new("R_ARC_N24           0xa   bits24    bitfield    S-A")
Relocation.new("R_ARC_N32           0xb   word32    bitfield    S-A")
Relocation.new("R_ARC_SDA           0xc   disp9     bitfield    S+A")
Relocation.new("R_ARC_SECTOFF       0xd   word32    bitfield    (S-SECTSTART)+A")

# arcompact elf me reloc
Relocation.new("R_ARC_S21H_PCREL    0xe   disp21h   signed      (S+A-P)>>1 (convert to halfword displacement)")
Relocation.new("R_ARC_S21W_PCREL    0xf   disp21w   signed      (S+A-P)>>2 (convert to longword displacement)")
Relocation.new("R_ARC_S25H_PCREL    0x10  disp25h   signed      (S+A-P)>>1 (convert to halfword displacement)")
Relocation.new("R_ARC_S25W_PCREL    0x11  disp25w   signed      (S+A-P)>>2 (convert to longword displacement)")
Relocation.new("R_ARC_SDA32         0x12  word32    signed      (S+A)-_SDA_BASE_")
Relocation.new("R_ARC_SDA_LDST      0x13  disp9ls   signed      (S+A-_SDA_BASE_) (s9 range)")
Relocation.new("R_ARC_SDA_LDST1     0x14  disp9ls   signed      (S+A-_SDA_BASE_)>>1 (s10 range)")
Relocation.new("R_ARC_SDA_LDST2     0x15  disp9ls   signed      (S+A-_SDA_BASE_)>>2 (s11 range)")
Relocation.new("R_ARC_SDA16_LD      0x16  disp9s    signed      (S+A-_SDA_BASE_) (s9 range)")
Relocation.new("R_ARC_SDA16_LD1     0x17  disp9s    signed      (S+A-_SDA_BASE_)>>1 (s10 range)")
Relocation.new("R_ARC_SDA16_LD2     0x18  disp9s    signed      (S+A-_SDA_BASE_)>>2 (s11 range)")
Relocation.new("R_ARC_S13_PCREL     0x19  disp13s   signed      (S+A-P)>>2")

# Unsupported
Relocation.new("R_ARC_W             0x1a  word32    bitfield    (S+A)&~3 (word-align)")

# arcompact elf me reloc
Relocation.new("R_ARC_32_ME         0x1b  limm      signed      S+A (MES)")
# TODO: This is a test relocation
Relocation.new("R_ARC_32_ME_S       0x69  limms     signed      S+A (MES)")

# Unsupported
Relocation.new("R_ARC_N32_ME        0x1c  word32    bitfield    S-A (MES)")
Relocation.new("R_ARC_SECTOFF_ME    0x1d  word32    bitfield    (S-SECTSTART)+A (MES)")

# arcompact elf me reloc
Relocation.new("R_ARC_SDA32_ME      0x1e  limm      signed      (S+A)-_SDA_BASE_ (MES)")

# Unsupported
Relocation.new("R_ARC_W_ME          0x1f  word32    bitfield    (S+A) & ~3 (word-aligned MES)")
Relocation.new("R_AC_SECTOFF_U8     0x23  disp9ls   bitfield    S+A-SECTSTART")
Relocation.new("R_AC_SECTOFF_U8_1   0x24  disp9ls   bitfield    (S+A-SECTSTART)>>1")
Relocation.new("R_AC_SECTOFF_U8_2   0x25  disp9ls   bitfield    (S+A-SECTSTART)>>2")
Relocation.new("R_AC_SECTFOFF_S9    0x26  disp9ls   bitfield    S+A-SECTSTART")
Relocation.new("R_AC_SECTFOFF_S9_1  0x27  disp9ls   bitfield    (S+A-SECTSTART)>>1")
Relocation.new("R_AC_SECTFOFF_S9_2  0x28  disp9ls   bitfield    (S+A-SECTSTART)>>2")
Relocation.new("R_ARC_SECTOFF_ME_1  0x29  word32    bitfield    ((S-SECTSTART)+A)>>1 (MES)")
Relocation.new("R_ARC_SECTOFF_ME_2  0x2a  word32    bitfield    ((S-SECTSTART)+A)>>2 (MES)")
Relocation.new("R_ARC_SECTOFF_1     0x2b  word32    bitfield    ((S-SECTSTART)+A)>>1")
Relocation.new("R_ARC_SECTOFF_2     0x2c  word32    bitfield    ((S-SECTSTART)+A)>>2")

Relocation.new("R_ARC_SDA16_ST2     0x30  disp9s    signed      (S+A-_SDA_BASE_)>>2 (Dsiambiguation for several relocations)")

# arcompact elf me reloc
Relocation.new("R_ARC_PC32          0x32  word32    signed      S+A-P")

# Special
Relocation.new("R_ARC_GOT32         0x3b  word32    dont        G+A") # == Special

# arcompact elf me reloc
Relocation.new("R_ARC_GOTPC32       0x33  word32    signed      GOT+G+A-P")
Relocation.new("R_ARC_PLT32         0x34  word32    signed      L+A-P")
Relocation.new("R_ARC_COPY          0x35  none      signed      none")
Relocation.new("R_ARC_GLOB_DAT      0x36  word32    signed      S")
Relocation.new("R_ARC_JMP_SLOT      0x37  word32    signed      S")
Relocation.new("R_ARC_RELATIVE      0x38  word32    signed      B+A")
Relocation.new("R_ARC_GOTOFF        0x39  word32    signed      S+A-GOT")
Relocation.new("R_ARC_GOTPC         0x3a  word32    signed      GOT+A-P")

Relocation.new("R_ARC_S21W_PCREL_PLT         0x3c  disp21w    signed      (L+A-P)>>2")
Relocation.new("R_ARC_S25H_PCREL_PLT         0x3d  disp25h    signed      (L+A-P)>>1")

Relocation.new("R_ARC_TLS_DTPMOD    0x42  word32    dont        0") # , 0, 2, 32, FALSE, 0, arcompact_elf_me_reloc, "R_ARC_TLS_DTPOFF",-1),
Relocation.new("R_ARC_TLS_DTPOFF    0x43  word32    dont        0") # , 0, 2, 32, FALSE, 0, arcompact_elf_me_reloc, "R_ARC_TLS_DTPOFF",-1),
Relocation.new("R_ARC_TLS_TPOFF     0x44  word32    dont        0") # ,"R_ARC_TLS_TPOFF"),
Relocation.new("R_ARC_TLS_GD_GOT    0x45  word32    dont        0") # , 0, 2, 32, FALSE, 0, arcompact_elf_me_reloc, "R_ARC_TLS_GD_GOT",-1),
Relocation.new("R_ARC_TLS_GD_LD     0x46  word32    dont        0") # ,"R_ARC_TLS_GD_LD"),
Relocation.new("R_ARC_TLS_GD_CALL   0x47  word32    dont        0") # ,"R_ARC_TLS_GD_CALL"),
Relocation.new("R_ARC_TLS_IE_GOT    0x48  word32    dont        0") # , 0, 2, 32, FALSE, 0, arcompact_elf_me_reloc, "R_ARC_TLS_IE_GOT",-1),
Relocation.new("R_ARC_TLS_DTPOFF_S9 0x49  word32    dont        0") # , 0, 2, 32, FALSE, 0, arcompact_elf_me_reloc, "R_ARC_TLS_DTPOFF_S9",-1),
Relocation.new("R_ARC_TLS_LE_S9     0x4a  word32    dont        0") # , 0, 2, 9, FALSE, 0, arcompact_elf_me_reloc, "R_ARC_TLS_LE_S9",-1),
Relocation.new("R_ARC_TLS_LE_32     0x4b  word32    dont        0") # , 0, 2, 32, FALSE, 0, arcompact_elf_me_reloc, "R_ARC_TLS_LE_32",-1),

Relocation.new("R_ARC_SPE_SECTOFF")

Relocation.new("R_ARC_S25W_PCREL_PLT         0x4c  disp25w    signed      (L+A-P)>>2")
Relocation.new("R_ARC_S21H_PCREL_PLT         0x4d  disp21h    signed      (L+A-P)>>1")

# Missing ones 
#  /* A 26 bit absolute branch, right shifted by 2.  */
#  ARC_RELA_HOWTO (R_ARC_B26  ,2 ,2 ,26,FALSE,0,bfd_elf_generic_reloc, == 0x5
#		  "R_ARC_B26",0xffffff),
#  /* A relative 22 bit branch; bits 21-2 are stored in bits 26-7.  */
#  ARC_RELA_HOWTO (R_ARC_B22_PCREL,2,2,22,TRUE,7,arc_elf_b22_pcrel,   == 0x6
#		  "R_ARC_B22_PCREL",0x7ffff80),
#  ARC_RELA_HOWTO (R_ARC_H30 ,2 ,2 ,32, FALSE, 0, bfd_elf_generic_reloc, == 0x7
#		  "R_ARC_H30",-1),

# Missing ones == Are declared as unsupported anyway
#  ARC_UNSUPPORTED_HOWTO (R_ARC_H30_ME,"R_ARC_H30_ME"), // == 0x20
#  ARC_UNSUPPORTED_HOWTO (R_ARC_SECTOFF_U8,"R_ARC_SECTOFF_U8"), // == 0x21
#  ARC_UNSUPPORTED_HOWTO (R_ARC_SECTOFF_S9,"R_ARC_SECTOFF_S9"), // == 0x22

#    RELOC_NUMBER (R_ARC_SECTOFF_U8, 0x21)
#    RELOC_NUMBER (R_ARC_SECTOFF_S9, 0x22)
