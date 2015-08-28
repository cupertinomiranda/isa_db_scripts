class BitReplacement < Enumerator
  @@container = []
  attr_reader :operand_type, :replacement_mask

  def self.each
    @@container.each { |a| yield(a) }
  end

  def self.find_for_instruction_operand(inst_op)
    matches = @@container.select { |v| v.operand_type == inst_op.operand_type && v.replacement_mask == inst_op.replacement_mask }

    return matches[0] if matches.count > 0
    return nil
  end

  def initialize(opt, mask)
    @operand_type = opt
    @replacement_mask = mask

    @@container <<= self
  end

  def ignore_bits
    return 0 unless operand_type.size_known?
    return operand_type.size - replacement_mask.number_of_bits
  end

  def name
    operand_type.assembler_name
  end


  def replacements_old
    mask = replacement_mask.mask.split('')
#    print mask
    symbol_used = ignore_bits
#    puts "BLA"
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
  def first_bit_with(letter)
    count = 0
    mask = replacement_mask.mask.split('')
    mask.each do |v|
      if(v =~ /#{letter}/)
	     return count
      end
      count += 1
    end
    return nil
  end

  def size_with(letter)
    mask = replacement_mask.mask.split('')
    size = 0
    mask.each do |v|
      if(v =~ /#{letter}/)
	     size += 1
	    end
    end
    return size
  end

  def name
    nametype = operand_type.assembler_name
    nametype = "#{nametype}A" if ((nametype =~ /^Z$/) && number == 0)
    nametype = "#{nametype}B" if ((nametype =~ /^Z$/) && number == 1)
    nametype = "#{nametype}C" if ((nametype =~ /^Z$/) && number == 2)
    nametype = "#{nametype}D" if (double_reg? && operand_type.register? && ((nametype !~ /^Z/) && nametype !~ /^W[0-9]+/))


    if (operand_type.simm?)
      #fbmsk = bit_replacement_mask.first_bit_with("1")
      fbmsk = instruction.opcode.index(/[su]/)
      nametype = "#{nametype}_A16" if (bits_in_mask == (operand_type.size - 1))
      nametype = "#{nametype}_A32" if (bits_in_mask == (operand_type.size - 2))
      nametype = "#{nametype}_AXX" if (bits_in_mask < (operand_type.size - 2))
      nametype = "#{nametype}_#{fbmsk}"
    end

    nametype = "#{nametype}_S" if (!instruction.long?)
    return nametype

  end

  def self.each_with_value_shift
    count = Hash.new
    OperandType.all.each do |op|
      next if op.name =~ /^1/ # Skip any fix value operands
      data = op.instruction_operands.select{ |iop| !iop.replacement_mask.is_empty? }.map do |iop|
	verify_alignment = nil
	ignore_bits = 0
	if(op.register?)
	  verify_alignment = 1 if iop.double_reg?
	else
	  ignore_bits = op.size - iop.bits_in_mask
	end
	name = iop.assembler_name
	{ 
	  name: iop.assembler_name, 
	  op_name: op.name, 
	  mask: iop.replacement_mask.mask_without_limm,
	  ignore_bits: ignore_bits,
	  verify_alignment: verify_alignment,
	  use_replace_func: iop.replacement_mask.name
	}
      end
      data.uniq!


      STDERR.puts data
      STDERR.puts "--------"

      data.each do |elem|
	elem[:repl_mask] = ReplacementMask.first(mask: elem[:mask])
        yield(op, elem)
      end

      #data1 = Hash.new()
      #data.each do |d|
      #  data1[d[:name]] = [] if data1[d[:name]] == nil
      #  data1[d[:name]].push(d)
      #end 

	#if(count[name].nil?)
	#  count[name] = 0
	#else
	#  count[name] = count[name] + 1
	#end
    end

    return

    BitReplacement.each do |bit_repl|
      op = bit_repl.operand_type
      data = op.instruction_operands.map do |iop| 
	{ name: iop.assembler_name, ignore_bits: (op.register? ? 0 : op.size - iop.bits_in_mask) }
      end
      data.uniq!

      STDERR.puts data
      STDERR.puts "--------"
      data.each do |d|
	yield(bit_repl, d[:name], d[:ignore_bits])
      end
      

      #names = bit_repl.operand_type.instruction_operands.map { |iop| iop.assembler_name }.uniq { |a| a }

      #STDERR.puts "# #{names.join(';')}"
      #names.each do |name|
      #  instructions = bit_repl.operand_type.instruction_operands
      #  		  .select{ |iop| iop.assembler_name == name }
      #  		  .map{ |iop| iop.instruction }
      #  STDERR.puts "#{bit_repl.replacement_mask.mask}: #{name}"
      #  instructions[0..10].each do |i|
      #    STDERR.puts "  #{i.mnemonic} => #{i.opcode}"
      #  end
      #  yield(bit_repl, name, instructions)	
      #  yield(bit_repl)

      #end
      

      #instructions = bit_repl.operand_type.instruction_operands.map { |iop| iop.instruction }
      #elems = bit_repl.operand_type.instruction_operands.uniq { |o| o.assembler_name }
      #instructions = bit_repl.operand_type.instruction_operands.map { |iop| iop.instruction }

      #elems.each do |iop|
      #  STDERR.puts "#{bit_repl.replacement_mask.mask}: #{iop.assembler_name} #{iop.number}"
      #  yield(bit_repl, iop, instructions) 
      #end
    end
  end

  def typer
    typer = []
    if operand_type.signed?
      typer.push("ARC_OPERAND_SIGNED")
    elsif operand_type.register?
      typer.push("ARC_OPERAND_IR") 
    else
      typer.push("ARC_OPERAND_UNSIGNED")
    end

    case ignore_bits
      when 1
	typer.push("ARC_OPERAND_ALIGNED16")
      when 2
	typer.push("ARC_OPERAND_ALIGNED32")
    end

    if ignore_bits >0
      typer.push ("ARC_OPERAND_TRUNCATE")
    end

    return typer
  end
end
