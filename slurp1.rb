# require 'rubygems'
# require 'nokogiri'
# require 'open-uri'

require 'net/http'
require 'uri'
require 'json'

@debug = true
@api_key = '4kk79ff2fxh2fcurhz5pnq97'
@required_words = "mobile"
@optional_words = "gaming games asdf"

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
  output[:overview] = data["overview"].nil? ? "" : data["overview"].gsub("\n", " ")
  output[:raised_amount] = data["investments"][0]["funding_round"]["raised_amount"].to_s rescue ""
  output[:raised_currency_code] = data["investments"][0]["funding_round"]["raised_currency_code"] rescue ""
  output[:funded_year] = data["investments"][0]["funding_round"]["funded_year"] rescue ""

  if !@required_words.empty? || !@optional_words.empty?
    searchable_fields = [:category_code, :tag_list, :description, :overview]
    searchable = ""
    searchable_fields.each { |field| searchable << " #{output[field]}" }

    unless @optional_words.empty?
      return nil unless search_optional(searchable)
    end

    unless @required_words.empty?
      return nil unless search_required(searchable)
    end
  end

  File.open('allCompanies.txt', 'a') {|f| f.write(output.values.join("|") + "\n") }
  puts "Finished getting company #{company}"
end

def search_optional(searchable)
  optional_found = false
  @optional_words.split(" ").each do |word|
    optional_found = true if searchable.include?(word)
  end
  optional_found
end

def search_required(searchable)
  required_found = true
  @required_words.split(" ").each do |word|
    required_found = false unless searchable.include?(word)
  end
  required_found
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
  getCompanyInfo('king')
else
  # run for all companies on crunchbase
  getCompanies
end
