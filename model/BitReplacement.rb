class BitReplacement < Enumerator
  @@container = []
  attr_reader :operand_type, :replacement_mask

  def self.each
    @@container.each { |a| yield(a) }
  end

  def self.find_for_instruction_operand(inst_op)
    return @@container.select { |v| v.operand_type == inst_op.operand_type && v.replacement_mask == inst_op.replacement_mask }[0]
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


  def replacements
    replacement_mask.replacements(ignore_bits) do |s,l,r|
      yield(s,l,r)
    end
  end

  def self.each_with_value_shift
    BitReplacement.each do |bit_repl|
      instructions = bit_repl.operand_type.instruction_operands.map { |iop| iop.instruction }
      elems = bit_repl.operand_type.instruction_operands.uniq { |o| o.number }
      elems.each do |iop|
        yield(bit_repl, iop, instructions) 
      end
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
