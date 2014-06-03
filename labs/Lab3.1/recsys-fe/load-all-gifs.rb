require 'rubygems'
require 'fastercsv'
require 'net/http'
require 'open-uri'
require 'json'

def sanitize_filename(filename)
	return filename.gsub /[^\w\.\-]/, '_'
end

FasterCSV.foreach("items.100k.csv", { :col_sep => "|", :headers => false, :encoding => "UTF-8"} ) do |row|
	title = row[1]
	title = title.sub(/\(.+\)/, "").strip

	t1 = title.split(",")
	if (t1.length == 1)
		title2 = t1.first
	else
		title2 = t1.last.lstrip + " " + t1.first
	end
	

	print("retrieving meta information for: *" + title + "*\n")

	s1 = "http://www.omdbapi.com/?t="+title
	s2 = URI::encode(s1)
	resp = Net::HTTP.get_response(URI.parse(s2))
	result = JSON.parse(resp.body)

	if (result["Response"] == "False") then 
		print("retry, retrieving meta information for: *" + title2 + "*\n")
		s1 = "http://www.omdbapi.com/?t="+title2
		s2 = URI::encode(s1)
		resp = Net::HTTP.get_response(URI.parse(s2))
		result = JSON.parse(resp.body)		
	end
	if (result["Response"] == "False" || result["Poster"] == "N/A") then
		print("Can't find movie: " + title + "\n")
		url = 'http://www.americanhumanefilmtv.org/wp-content/uploads/2011/11/genericMoviePoster-202x300.jpg'
	else
		url = result["Poster"]
	end

	print("downloading: " + url + "\n")

	fname = sanitize_filename(title + '.jpg')
	pathname = 'public/images/' + fname
	File.open(pathname, 'wb') do |saved_file|
		open(url, 'rb') do |read_file|
			saved_file.write(read_file.read)
		end
	end			
end

