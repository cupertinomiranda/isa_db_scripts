require 'rubygems'
require 'smart_csv'

$:.push(Dir.pwd)

require 'dbSetup'

exit 0 if ARGV.count < 1
file = ARGV[0]

puts "Reading #{file}"

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

cleanDatabase

line = 0
data.each do |elem|
	#print elem
	line += 1

	mnemonic = elem['Mnemonic']
	if(mnemonic !~ /^\s*$/)
		opcode = ''
		32.times do |n|
			n -= 1
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

			flagZ: elem['Flag: Z'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
			flagN: elem['Flag: N'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
			flagC: elem['Flag: C'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
			flagV: elem['Flag: V'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
			flagS: elem['Flag: S'] == 'Y' ? true : (elem['Flag:Z'] == 'N' ? false : nil),
		})

		# Setup Operand related tables (InstructionOperand, Operand)
		3.times do |op_n|
			op_name = elem["Opr#{op_n}"]
			if(op_name !~ /^\s*$/)
				operand_type = OperandType.first(name: op_name)
				if(operand_type.nil?)
					operand_type = OperandType.create({
						name: op_name
					})
				end


				instruction_operand = InstructionOperand.new({
					number: op_n
				})
				instruction_operand.operand_type = operand_type
				instruction_operand.instruction = instruction
				instruction_operand.save!
			end
		end
	end


end

