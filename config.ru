require 'rubygems'
require 'bundler/setup'

PassengerRuby /usr/local/rvm/gems/ruby-2.1.0/wrappers/ruby

require "./app"
run Sinatra::Application
