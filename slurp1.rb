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

def getCompanyInfo(company)
  url = "http://api.crunchbase.com/v/1/company/#{company}.js?api_key=#{@api_key}"
  #page_contents = Nokogiri::HTML(open(@site_url))
  
  page_contents = Net::HTTP.get(URI.parse(url))
  
  data = JSON.parse(page_contents)
  output = Hash.new
  output[:name] = data["name"]
  output[:homepage_url] = data["homepage_url"]
  output[:founded_year] = data["founded_year"].to_s
  output[:category_code] = data["category_code"]
  output[:tag_list] = data["tag_list"]
  output[:description] = data["description"]
  output[:overview] = data["overview"]
  output[:raised_amount] = data["investments"][0]["funding_round"]["raised_amount"].to_s rescue ""
  output[:raised_currency_code] = data["investments"][0]["funding_round"]["raised_currency_code"] rescue ""
  output[:funded_year] = data["investments"][0]["funding_round"]["funded_year"] rescue ""

  File.open('allCompanies.json', 'a') {|f| f.write(output.values.join("|") + "\n") }
  puts "Finished getting company #{company}"
  

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
