require 'rubygems'
require 'smart_csv'

exit 0 if ARGV.count < 1
file = ARGV[0]
puts "Reading #{file}"

$:.push(Dir.pwd)
require 'dbSetup'
clean_database
initialize_tables

def create_mask_from(opcode, letter)
  letter = letter.downcase
  opcode.chars.map { |c| (c =~ /#{letter}/i || c =~ /#{letter.upcase}/) ? c : 0 }.join('')
end
