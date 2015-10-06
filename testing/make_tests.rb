#!/usr/bin/ruby

require 'erb'
require_relative '../init.rb'

project_root = File.dirname(File.absolute_path(__FILE__))

output_path = ENV["BINUTILS_PATH"] || project_root + "/test_output/"
ld_output_path = "#{output_path}/ld/testsuite/ld-arc/relocs"
as_output_path = "#{output_path}/as/testsuite/as-arc/relocs"

`mkdir -p #{ld_output_path}`
`mkdir -p #{as_output_path}`

@tests = []

test_exp_renderer  = ERB.new(File.open(project_root + "/templates/arc_reloc.exp.erb").read)
assembly_renderer  = ERB.new(File.open(project_root + "/templates/reloc_test.s.erb").read)
validator_renderer = ERB.new(File.open(project_root + "/templates/reloc_test.d.erb").read)

def for_each_reloc_insn_tupple 
  Relocation.each do |reloc| 
    next if reloc.type =~ /none/
    reloc.replacement_mask.instruction_operands.each do |io| 
      yield(reloc, io)
    end
  end
end

count = 0;
for_each_reloc_insn_tupple do
  count += 1
end

progressbar = ProgressBar.create( 
                                  :format         => '%a (%c/%C) %b|%i %p%% %t',
                                  :starting_at    => 0,
                                  :total          => count)

count = 0
for_each_reloc_insn_tupple do |reloc, io|
  @reloc = reloc

  @insn = io.instruction 
  @operand_reloc_number = io.number

  # Linker test code
  f = File.open(ld_output_path + "/#{@reloc.name}__#{@insn.mnemonic.downcase}__#{count}.s", "w")
  f.write(assembly_renderer.result);
  f.close
  # Assembler test code
  f = File.open(as_output_path + "/#{@reloc.name}__#{@insn.mnemonic.downcase}__#{count}.s", "w")
  f.write(assembly_renderer.result);
  f.close

  # Linker validation files
  f = File.open(ld_output_path + "/#{@reloc.name}__#{@insn.mnemonic.downcase}__#{count}.d", "w")
  f.write(validator_renderer.result);
  f.close
  # Assembler validation files
  f = File.open(as_output_path + "/#{@reloc.name}__#{@insn.mnemonic.downcase}__#{count}.d", "w")
  f.write(validator_renderer.result);
  f.close

  @tests.push("#{@reloc.name}__#{@insn.mnemonic.downcase}__#{count}")
  progressbar.increment
  count += 1
end

f = File.open(ld_output_path + "/reloc.exp", "w")
f.write(test_exp_renderer.result);
f.close
f = File.open(as_output_path + "/reloc.exp", "w")
f.write(test_exp_renderer.result);
f.close

`cp relocs.ld #{ld_output_path}/`
`cp relocs.ld #{as_output_path}/`

exit 0
