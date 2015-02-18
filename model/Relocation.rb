class Relocation < Enumerator
	@@container = []
	attr_reader :name, :value

	def self.each
		@@container.each { |a| yield(a) }
	end

	def initialize(string)
		data = string.split(/[\s\t]+/)
		if(data.count >= 4)
			@name = data[0]
			@value = data[1].to_i(16)
			@type = data[2]
			@calc = data[3]
			@info = data[4] # Only informational no real used

		  @@container <<= self
		end

		#puts "Reloc #{name} => #{value}"

	end

	def type_compatible?(t)
		return true if (@type =~ )

		return false
	end
end


Relocation.new("R_ARC_NONE				 	0x0 		none		  none")
Relocation.new("R_ARC_8 						0x1 		bits8 		S+A")
Relocation.new("R_ARC_16						0x2 		bits16 		S+A")
Relocation.new("R_ARC_24 						0x3 		bits24 		S+A")
Relocation.new("R_ARC_32 						0x4 		word32 		S+A")
Relocation.new("R_ARC_N8 						0x8 		bits8 		S-A")
Relocation.new("R_ARC_N16 					0x9 		bits16 		S-A")
Relocation.new("R_ARC_N24 					0xa 		bits24 		S-A")
Relocation.new("R_ARC_N32 					0xb 		word32 		S-A")
Relocation.new("R_ARC_SDA 					0xc 		disp9 		S+A")
Relocation.new("R_ARC_SECTOFF 			0xd 		word32 		(S-SECTSTART)+A")
Relocation.new("R_ARC_S21H_PCREL 		0xe 		disp21h		(S+A-P)>>1 (convert to halfword displacement)")
Relocation.new("R_ARC_S21W_PCREL 		0xf 		disp21w 	(S+A-P)>>2 (convert to longword displacement)")
Relocation.new("R_ARC_S25H_PCREL 		0x10 		disp25h 	(S+A-P)>>1 (convert to halfword displacement)")
Relocation.new("R_ARC_S25W_PCREL 		0x11 		disp25w 	(S+A-P)>>2 (convert to longword displacement)")
Relocation.new("R_ARC_SDA32 				0x12 		word32 		(S+A)-_SDA_BASE_")
Relocation.new("R_ARC_SDA_LDST 			0x13 		disp9ls 	(S+A-_SDA_BASE_) (s9 range)")
Relocation.new("R_ARC_SDA_LDST1 		0x14 		disp9ls 	(S+A-_SDA_BASE_)>>1 (s10 range)")
Relocation.new("R_ARC_SDA_LDST2 		0x15 		disp9ls 	(S+A-_SDA_BASE_)>>2 (s11 range)")
Relocation.new("R_ARC_SDA16_LD 			0x16 		disp9s 		(S+A-_SDA_BASE_) (s9 range)")
Relocation.new("R_ARC_SDA16_LD1 		0x17 		disp9s 		(S+A-_SDA_BASE_)>>1 (s10 range)")
Relocation.new("R_ARC_SDA16_LD2 		0x18 		disp9s 		(S+A-_SDA_BASE_)>>2 (s11 range)")
Relocation.new("R_ARC_S13_PCREL 		0x19 		disp13s 	(S+A-P) >>2")
Relocation.new("R_ARC_W 						0x1a 		word32 		(S+A) & ~3 (word-align)")
Relocation.new("R_ARC_32_ME 				0x1b 		word32 		S+A (MES)")
Relocation.new("R_ARC_N32_ME 				0x1c 		word32 		S-A (MES)")
Relocation.new("R_ARC_SECTOFF_ME 		0x1d 		word32 		(S-SECTSTART)+A (MES)")
Relocation.new("R_ARC_SDA32_ME 			0x1e 		word32 		(S+A)-_SDA_BASE_ (MES)")
Relocation.new("R_ARC_W_ME 					0x1f 		word32 		(S+A) & ~3 (word-aligned MES)")
Relocation.new("R_AC_SECTOFF_U8 		0x23 		disp9ls 	S+A-SECTSTART")
Relocation.new("R_AC_SECTOFF_U8_1 	0x24 		disp9ls 	(S+A-SECTSTART)>>1")
Relocation.new("R_AC_SECTOFF_U8_2 	0x25 		disp9ls 	(S+A-SECTSTART)>>2")
Relocation.new("R_AC_SECTFOFF_S9 		0x26 		disp9ls 	S+A-SECTSTART")
Relocation.new("R_AC_SECTFOFF_S9_1 	0x27 		disp9ls 	(S+A-SECTSTART)>>1")
Relocation.new("R_AC_SECTFOFF_S9_2 	0x28 		disp9ls 	(S+A-SECTSTART)>>2")
Relocation.new("R_ARC_SECTOFF_ME_1 	0x29 		word32 		((S-SECTSTART)+A)>>1 (MES)")
Relocation.new("R_ARC_SECTOFF_ME_2 	0x2a 		word32 		((S-SECTSTART)+A)>>2 (MES)")
Relocation.new("R_ARC_SECTOFF_1 		0x2b 		word32 		((S-SECTSTART)+A)>>1")
Relocation.new("R_ARC_SECTOFF_2 		0x2c 		word32 		((S-SECTSTART)+A)>>2")
Relocation.new("R_ARC_PC32 					0x32 		word32 		S+A-P")
Relocation.new("R_ARC_GOT32 				0x3b 		word32 		G+A")
Relocation.new("R_ARC_GOTPC32 			0x33 		word32 		GOT+G+A-P")
Relocation.new("R_ARC_PLT32 				0x34 		word32 		L+A-P")
Relocation.new("R_ARC_COPY 					0x35 		none 			none")
Relocation.new("R_ARC_GLOB_DAT 			0x36 		word32 		S")
Relocation.new("R_ARC_JMP_SLOT 			0x37 		word32 		S")
Relocation.new("R_ARC_RELATIVE 			0x38 		word32 		B+A")
Relocation.new("R_ARC_GOTOFF 				0x39 		word32 		S+A-GOT")
Relocation.new("R_ARC_GOTPC 				0x3a 		word32 		GOT+A-P")
Relocation.new("R_ARC_SPE_SECTOFF")
