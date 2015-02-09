require 'rubygems'
require 'data_mapper' # requires all the gems listed above
require 'dm-migrations'

# If you want the logs displayed you have to do this before the call to setup
#DataMapper::Logger.new($stdout, :debug)

# An in-memory Sqlite3 connection:
#DataMapper.setup(:default, 'sqlite::memory:')

# A Sqlite3 connection to a persistent database

PWD=Dir.pwd

DataMapper.setup(:default, "sqlite://#{PWD}/isa.db")
Dir["#{Dir.pwd}/dbmodel/*.rb"].each do |file| 
	require file.split('.')[0]
	#puts "Loading #{file}"
end
DataMapper.finalize
DataMapper.auto_upgrade!

def cleanDatabase
	#DataMapper.drop
	DataMapper.auto_migrate!
end
