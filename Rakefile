OUTPUT_DIR = "#{Dir.pwd}/output"
DB_FILE = "#{Dir.pwd}/db/isa.db"

directory OUTPUT_DIR

namespace "gen" do
	task :dump => [OUTPUT_DIR] do
		`erb templates/dump.erb > "#{OUTPUT_DIR}/dump.c"`
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
