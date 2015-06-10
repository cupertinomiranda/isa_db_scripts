file_root = File.dirname(File.absolute_path(__FILE__))
OUTPUT_DIR = "#{file_root}/output"
DB_FILE = "#{file_root}/db/isa.db"
BINUTILS_SRC = ENV['BINUTILS_SRC']

directory OUTPUT_DIR

namespace "gen" do
  
  desc "Generate files needed for binutils. Binutils Path should be given in env variable BINUTILS_SRC"
  task :binutils do
    if(BINUTILS_SRC.nil?)
      puts "This task requires the env var BINUTILS_SRC to point to the binutils src directory."
      exit(1)
    end
    puts BINUTILS_SRC
    `erb templates/reloc.def.erb > "#{BINUTILS_SRC}/include/elf/arc_reloc.def"`
    `erb templates/reloc_value_type.h.erb > "#{BINUTILS_SRC}/include/elf/arc_reloc_type.h"`
    `erb templates/opc.c.erb > "#{BINUTILS_SRC}/include/elf/arc_opc.c"`
  end

end

namespace "db" do
  directory "#{Dir.pwd}/db"
  
  desc "Just load the database engine to verify if evrything is Ok."
  task :test_loading => "#{Dir.pwd}/db" do
    require_relative 'init.rb'
  end
  
  desc "Create an empty database"
  task :create => [:load_db_model] do
    DataMapper.auto_migrate!
  end
  
  desc "Delete the database"
  task :destroy do
    `rm -f #{DB_FILE}`
  end
  
  desc "Create the database from CSV. \n Should provide the env vars DB_FILE and CSV."
  task :import => [:destroy] do
    csv = ENV["CSV"] || ""
    if(ENV["CSV"].nil?)
      puts "This task requires that CSV environment variable is set."
      exit 1;
    end
  
    require_relative 'dbSetup'
    clean_database
    initialize_tables
    create_database_with_csv(ENV["CSV"])
  end
end

