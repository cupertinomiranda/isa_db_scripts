#!/usr/bin/ruby

require 'erb'
require_relative 'init.rb'

project_root = File.dirname(File.absolute_path(__FILE__))

output_path = project_root + "/test_output/"

assembly_renderer = ERB.new(File.open(project_root + "/templates/test/reloc_test.s.erb").read)
validator_renderer = ERB.new(File.open(project_root + "/templates/test/reloc_test.s.erb").read)

count = 0;
Relocation.each do |reloc| 
  puts reloc.type
  next if reloc.type =~ /none/
  reloc.replacement_mask.instruction_operands.each do |io| 
    @reloc = reloc

    @insn = io.instruction 
    @operand_reloc_number = io.number

    puts "#{reloc.name}_#{@insn.mnemonic}"

    f = File.open(output_path + "#{@reloc.name}__#{@insn.mnemonic.downcase}__#{count}.s", "w")
    f.write(assembly_renderer.result);
    f.close
    count += 1
  end
end

exit 0
