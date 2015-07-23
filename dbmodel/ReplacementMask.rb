class ReplacementMask
  include DataMapper::Resource

  property :id,   Serial
  property :mask, String, :length => 128
  property :name, String

  has n, :instruction_operands

  def size
    mask.split('').count
  end

  def reloc_mask
    first = 0
    last = mask.length
    if(mask.length > 32)
      first = mask.length - 32
    end

    return mask.split("")[first..last].join("")
  end

  def reloc_size
    return 8 if size <= 8
    return 16 if size <= 16
    return 32 if size <= 32
    return 32 # No relocs are bigger than 32, force anything bigger to be in 32 reloc
  end

  def number_of_bits
    mask.split('').select { |b| b != '0' }.count
  end

  def self.create_with_string(string)
    data = string.split(/[\s\t]+/)
    ReplacementMask.create({
      name: data[0],
      mask: data[1]
    })
  end
  def self.initialize_table
    self.create_with_string("none     00000000000000000000000000000000")

    self.create_with_string("bits8    11111111")
    self.create_with_string("bits16   1111111111111111")
    self.create_with_string("bits24   111111111111111111111111")
    self.create_with_string("word32   11111111111111111111111111111111")

    self.create_with_string("limm     0000000000000000000000000000000011111111111111111111111111111111")
    self.create_with_string("limms    000000000000000011111111111111111111111111111111")

    self.create_with_string("disp21h  00000111111111102222222222000000")
    self.create_with_string("disp21w  00000111111111002222222222000000")

    self.create_with_string("disp25h  00000111111111102222222222003333")
    self.create_with_string("disp25w  00000111111111002222222222003333")

    self.create_with_string("disp9    00000000000000000000000111111111")
    self.create_with_string("disp9ls  00000000111111112000000000000000")

    self.create_with_string("disp9s   0000000111111111")

    self.create_with_string("disp13s  0000011111111111")

    self.create_with_string("disp9s1  0000022222200111")
  end

  def first_bit_with(letter)
    count = 0
    mask = self.reloc_mask.split('')
    mask.each do |v|
      if(v =~ /#{letter}/)
	     return count
      end
      count += 1
    end
    return nil
  end

  def size_with(letter)
    mask = self.reloc_mask.split('')
    size = 0
    mask.each do |v|
      if(v =~ /#{letter}/)
	     size += 1
	    end
    end
    return size
  end

  def replacements(ignore_bits = 0)
    mask = self.reloc_mask.split('')

    symbol_used = ignore_bits
    [1,2,3,4].each do |i|
      loc = first_bit_with("#{i}")
      size = size_with("#{i}")

      if(!loc.nil?)
        opcode_size = mask.count
        repl_mask = "0x%04x" % ((2**size) - 1)
        loc = opcode_size - loc - size
        
        yield(symbol_used, loc, repl_mask)
        
        symbol_used += size
      end
    end
  end
end
