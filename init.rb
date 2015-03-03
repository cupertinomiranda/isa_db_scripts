require 'rubygems'

load 'dbSetup.rb'

<<<<<<< HEAD
Dir["#{Dir.pwd}/parsers/*.rb"].each do |file| 
  #puts "Loading #{file}"
  load file
end

Dir["#{Dir.pwd}/model/*.rb"].each do |file| 
  #puts "Loading #{file}"

  load file
end

# Generate bit replacements
OperandType.all.each do |op|
  op.replacement_masks.each do |mask|
    BitReplacement.new(op, mask)
  end
end

