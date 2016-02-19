class ReplacementMask
  include DataMapper::Resource

  property :id,   Serial
  property :mask, String, :length => 128
  property :name, String

  has n, :instruction_operands

  def generated_name
    return name if name != nil 

    return "REPL_#{size}_#{mask_as_hex}"

  end

  def size
    mask.split('').count
  end
  def size_for_reloc
    return 0 if size <= 8
    return 1 if size <= 16
    return 2 if size <= 32
    return 2; # There are no relocs bigger then 32 bits
  end
  def size_for_read_write
    return 8 if size_for_reloc == 0
    return 16 if size_for_reloc == 1
    return 32 if size_for_reloc == 2
  end

  def mask_for_read_write
    n = 0
    n = size_for_read_write - size if size <= 32
    return "#{mask}#{ Array.new(n).map { |a| '0'}.join('') }"
  end
  def mask_without_limm
    return mask_for_read_write[0..(size-1-32)] if size > 32 && name.nil?
    return mask_for_read_write 
  end
  def mask_as_hex
    tmp = mask_without_limm.split('').map { |c| c == '0' ? '0' : '1' }.join('')
    "0x%02x" % tmp.to_i(2)
  end

  def reloc_mask
    first = 0
    last = mask_for_read_write.length
    if(mask_for_read_write.length > 32)
      first = mask_for_read_write.length - 32
    end

    return mask_for_read_write.split("")[first..last].join("")
  end

  def reloc_size
    return 8 if size <= 8
    return 16 if size <= 16
    return 32 if size <= 32
    return 32 # No relocs are bigger than 32, force anything bigger to be in 32 reloc
  end

  def bitsize 
    return number_of_bits
  end

  def number_of_bits
    mask.split('').select { |b| b != '0' }.count
  end
  def is_empty?
    return (number_of_bits == 0)
  end

  #def replacements(ignore_bits)
  #  mask = replacement_mask.mask.split('')
  #  symbol_used = ignore_bits
  #  [1,2,3,4].each do |i|
  #    loc = first_bit_with("#{i}")
  #    size = size_with("#{i}")

  #    if(!loc.nil?)
  #           opcode_size = mask.count
  #           repl_mask = "0x%04x" % ((2**size) - 1)
  #           loc = opcode_size - loc - size

  #           yield(symbol_used, loc, repl_mask)

  #           symbol_used += size
  #    end
  #  end
  #end

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
