require 'rubygems'
require 'data_mapper' # requires all the gems listed above
require 'dm-migrations'

# If you want the logs displayed you have to do this before the call to setup
#DataMapper::Logger.new($stdout, :debug)

# An in-memory Sqlite3 connection:
#DataMapper.setup(:default, 'sqlite::memory:')

# A Sqlite3 connection to a persistent database

PWD = Dir.pwd 
db_file = ENV['DB_FILE'] || "#{PWD}/isa.db"

DataMapper.setup(:default, "sqlite://#{db_file}")
DataMapper::Model.raise_on_save_failure = true
Dir["#{Dir.pwd}/dbmodel/*.rb"].each do |file| 
	load file
	#puts "Loading #{file}"
end
DataMapper.finalize
#DataMapper.auto_upgrade!

def initialize_tables
  ReplacementMask.initialize_table
end

def clean_database
	#DataMapper.drop
	DataMapper.auto_migrate!
end
