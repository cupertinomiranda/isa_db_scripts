#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'

$:.push("#{Dir.pwd}/../")

require 'dbSetup'
 
get '/' do
  @instruction = Instruction.all
  haml :index
end
	   
