require 'rubygems'
require 'sinatra'
require 'fastercsv'
require 'net/http'
require 'open-uri'
require 'json'

set :bind, '0.0.0.0'

def sanitize_filename(filename)
  return filename.gsub /[^\w\.\-]/, '_'
end

before do
	unless defined? $items
		# This way of loading all recommendations into memory is clearly not efficient
		# it's just for demo purpoases
		puts("Loading data...")
		$items = Hash.new("items")
		FasterCSV.foreach("items.csv", { :col_sep => "|", :headers => false, :encoding => "UTF-8"} ) do |row|
			$items[row[0]] = row[1]
		end
		$recom = Hash.new("recommendations")
		FasterCSV.foreach("rec_file.txt", { :col_sep => "\t", :headers => false, :encoding => "UTF-8"} ) do |row|
			s = row[1].gsub("[","").gsub("]","").split(",")
			movies = []
			s.each do |r|
				movies << r.split(":")[0]
			end
			$recom[row[0]] = movies
		end		
	end
end

get '/' do
	erb :recsys
end

get '/recom' do
	userid = params[:userid].to_i
	if (userid > $recom.length || userid <= 0)
		raise("invalid user id = " + params[:userid])
	end

	inx = $recom[params[:userid]]
	$posters = Array.new()
	inx.each do |i|
		title = $items[i].sub(/\(.+\)/, "").strip  # remove '(YEAR)' if exists
		fname = sanitize_filename(title + '.jpg')
		$posters.push 'images/' + fname

	end unless inx == nil
	erb :recshow
end

