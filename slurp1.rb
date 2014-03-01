# require 'rubygems'
# require 'nokogiri'
# require 'open-uri'

require 'net/http'
require 'uri'
require 'json'

@debug = false
@api_key = '4kk79ff2fxh2fcurhz5pnq97'

# class DashboardController < ActionController::Base
#  
#   def site\

def getCompanyInfo (company)
  url = "http://api.crunchbase.com/v/1/company/#{company}.js?api_key=#{@api_key}"
  #page_contents = Nokogiri::HTML(open(@site_url))
  
  page_contents = Net::HTTP.get(URI.parse(url))
  
    begin
      data = JSON.parse(page_contents)
      @companies[company]['data'] = data
    rescue
  File.open('allCompanies.json', 'a') {|f| f.write(@companies) }  
  puts "Finished getting company #{company}  "
  end
  

end
  
def getCompanies 
  url = "http://api.crunchbase.com/v/1/companies.js?api_key=#{@api_key}"
  
  page_contents = Net::HTTP.get(URI.parse(url))
  
  @companies = JSON.parse(page_contents)
  
  @companies.each do | company |
    getCompanyInfo(company["permalink"])
  end
  #File.open('allCompanies.json', 'w') {|f| f.write(@companies) }  
end
  
  
if @debug
  # run for only one company
  getCompanyInfo('originate')
else
  # run for all companies on crunchbase
  getCompanies
end
