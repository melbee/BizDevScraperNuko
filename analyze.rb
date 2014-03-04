# require 'rubygems'
# require 'nokogiri'
# require 'open-uri'

require 'json'

@companies = JSON.parse( IO.read('allCompanies.json')) 

@companies.each do | company |
  puts company
end