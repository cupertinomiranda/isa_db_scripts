require 'rubygems'
load 'init.rb'

reloc_names = Relocation.all.map { |r| r.name.slice(2,100) }

exit 0 if ARGV.count < 1
file = ARGV[0]
filename = ARGV[0].split('/')[-1]

`cp #{file} /tmp`

inside = false
IO.readlines("/tmp/#{filename}").each do |line|
  case line
    when /^--MARKER_ARC_RELOCS_BEGIN--$/
      inside = true
    when /^--MARKER_ARC_RELOCS_END--$/
      inside = false
    when /BFD_RELOC_([A-Z_0-9]+)/
      reloc_names.reject! { |name| $1 == name } if !inside
  end
end

f = File.open("#{file}", "w")
IO.readlines("/tmp/#{filename}").each do |line|
  line.chomp!
  case line
    when /^--MARKER_ARC_RELOCS_BEGIN--$/
      inside = true
      f.puts(line)
      reloc_names.each do |name| 
        f.puts("ENUM")
        f.puts("  BFD_RELOC_#{name}")
        f.puts("ENUMDOC")
        f.puts("  BFD_RELOC_#{name} Arc relocation.")
      end
      f.puts("--MARKER_ARC_RELOCS_END--")
      inside = true
    when /^--MARKER_ARC_RELOCS_END--$/
      inside = false
    else
      f.puts(line) if inside == false
  end
end
