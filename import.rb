require 'rubygems'
require 'smart_csv'

exit 0 if ARGV.count < 1
file = ARGV[0]
puts "Reading #{file}"

$:.push(Dir.pwd)
require 'dbSetup'
cleanDatabase


def create_mask_from(opcode, letter)
  letter = letter.downcase
  opcode.chars.map { |c| (c =~ /#{letter}/i || c =~ /#{letter.upcase}/) ? c : 0 }.join('')
end


headers = {}
data = []
count = 0

CSV.foreach(file) do |row|
  if(count == 0)
    i = 0		
    row.each do |h| 
      headers[i] = h; i += 1 
    end
  else
    i = 0
    d = {}
    row.each do |v|
      d[headers[i]] = v
      i += 1
    end
    data.push(d)
  end

  count += 1
end


# Setting up CpuVersion table 
cpus = headers.select { |k,v| v =~ /D: /}.map { |k,v| v.split(' ')[1..-1].join(' ') }
cpus.each do |cpu|
  CpuVersion.create(name: cpu);
end

line = 0
data.each do |elem|
  #print elem
  line += 1

  next if(line < 480 || line > 485)

  flags = ['aa', 'cc', 'd', 'di', 'f', 'T', 'x', 'zz']	
  mnemonic = elem['Mnemonic']
  if(mnemonic !~ /^\s*$/)
    opcode = ''
    32.times do |n|
      n = (n < 10) ? "0#{n}" : "#{n}"
      opcode = "#{elem[n]}#{opcode}"
    end

    if(opcode =~ /^\s*$/) 
      puts "Empty opcode for line #{line} with mnemonic #{mnemonic}"
    end

    # Create the instruction elements (Instruction)
    instruction = Instruction.create({
      mnemonic: elem['Mnemonic'],
      opcode: opcode,
      class: elem['Class'],			
      subclass: elem['Subclass'],

      #flagZ: elem['Flag: Z'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
      #flagN: elem['Flag: N'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
      #flagC: elem['Flag: C'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
      #flagV: elem['Flag: V'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
      #flagS: elem['Flag: S'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
    })

    # Setting up the flags
    flags.each do |flag|
      if(elem[flag] && elem[flag] !~ /^\s*$/)
        insn_flag = InstructionFlag.first(type: flag, mnemonic_patch: elem[flag])
        insn_flag = InstructionFlag.new(type: flag, mnemonic_patch: elem[flag]) if(insn_flag.nil?) 
        insn_flag.instructions <<= instruction
        insn_flag.save!
      end
    end

    # Setting up CpuVersion relations
    CpuVersion.all.each do |cpu|
      available = elem["D: #{cpu.name}"]
      if(available =~ /S/)
        ConditionalCpuInstructionRelation.create(instruction: instruction, cpu_version: cpu)	
      elsif(available =~ /U/)
        # Do nothing
      elsif(available =~ /O/)
        condition = elem["C: #{cpu.name}"]
        puts "Warning: Optional availability for instruction at line #{line} has empty condition for CPU version #{cpu.name}" if(condition.nil? || condition =~ /^\s*$/)
        ConditionalCpuInstructionRelation.create(
          condition: condition,
          instruction: instruction, 
          cpu_version: cpu
        )	
      else
        puts "Warning: Instruction at line #{line} has no information on availability for '#{cpu.name}' version."
      end

    end

    # Setup Operand related tables (InstructionOperand, Operand)
    operands = []

    3.times do |op_n|
      op_name = elem["Opr#{op_n+1}"]
      operands <<= op_name if(op_name && op_name !~ /^\s*$/)
    end

    op_n = 0
    operands.each do |op_name|
      operand_type = OperandType.first(name: op_name)
      if(operand_type.nil?)
        operand_type = OperandType.create({
          name: op_name
        })
      end

      instruction_operand = InstructionOperand.new({
        number: op_n,
      })
      instruction_operand.set_mask(instruction.opcode, op_name.chars.first, operands )
      instruction_operand.operand_type = operand_type
      instruction_operand.instruction = instruction
      instruction_operand.save!

      op_n += 1
    end
  end


end

