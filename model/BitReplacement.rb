class BitReplacement < Enumerator
	@@container = []
	attr_reader :operation_type, :replacement_mask

	def self.each
		@@container.each { |a| yield(a) }
	end

	def initialize(opt, mask)
		@operation_type = opt
		@replacement_mask = mask

		@@container <<= self
	end

	def ignore_bits
		return 0 unless operation_type.size_known?	
		return operation_type.size - replacement_mask.number_of_bits
	end

	def name
		ret = "#{operation_type.extended_name}"
		ret += "_#{2**(ignore_bits+3)}" if ignore_bits > 0
		ret
	end

	def replacements
		mask = replacement_mask.mask.split('')
		symbol_used = ignore_bits
		[1,2,3,4].each do |i|
			loc = nil
			size = 0
			count = 0
			mask.each do |v|
				if(v =~ /#{i}/)
					loc = count if(loc.nil?)
					size += 1
				end
				count += 1
			end

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
