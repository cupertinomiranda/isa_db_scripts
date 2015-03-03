OUTPUT_DIR = "#{Dir.pwd}/output"
DB_FILE = "#{Dir.pwd}/db/isa.db"
BINUTILS_SRC = ENV['BINUTILS_SRC']

directory OUTPUT_DIR

namespace "gen" do
	task :dump => [OUTPUT_DIR] do
		`erb templates/dump.erb > "#{OUTPUT_DIR}/dump.c"`
	end

        task :binutils => [BINUTILS_SRC] do
          `erb templates/reloc.def.erb > "#{BINUTILS_SRC}/include/elf/arc_reloc.def"`
          `erb templates/reloc_value_type.h.erb > "#{BINUTILS_SRC}/include/elf/arc_reloc_type.h"`
          `erb templates/opc.c.erb > "#{BINUTILS_SRC}/include/elf/arc_opc.c"`
        end

end

namespace :db do
	directory "#{Dir.pwd}/db"

	task :load_db_model => "#{Dir.pwd}/db" do
		load 'dbSetup.rb'
	end

	task :create => [:load_db_model] do
		DataMapper.auto_migrate!
	end

	task :destroy => [:load_db_model] do
		`rm #{DB_FILE}`
	end

	task :import => [:destroy] do
	  csv = ENV["CSV"] || ""
		`ruby import.rb #{csv}`
	end
end
