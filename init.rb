require 'rubygems'

load 'dbSetup.rb' 

Dir["#{Dir.pwd}/model/*.rb"].each do |file| 
	load file
end

# Generate bit replacements
OperandType.all.each do |op|
	op.replacement_masks.each do |mask| 
		BitReplacement.new(op, mask)	
	end
end
