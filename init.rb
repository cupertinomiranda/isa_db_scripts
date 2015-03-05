require 'rubygems'

require 'dbSetup'

LIBROOT = ENV['LIBROOT']

Dir["#{LIBROOT}/parsers/*.rb"].each do |file| 
  puts "Loading #{file}"
  load file
end

Dir["#{LIBROOT}/model/*.rb"].each do |file| 
  puts "Loading #{file}"

  load file
end

# Generate bit replacements
OperandType.all.each do |op|
  op.replacement_masks.each do |mask|
    BitReplacement.new(op, mask)
  end
end

