require 'csv'

$subway_data_2019 = CSV.parse(File.read("subway_data(2019).csv"), headers: true)
$subway_data_2020 = CSV.parse(File.read("subway_data(2020).csv"), headers: true)
$covid_data = CSV.parse(File.read("covid.csv"),headers: true)
$pos_data = CSV.parse(File.read("all_pos_data.csv"),headers: true)

def covid_file_gen
	# initialize $covid_hash
	covid_hash = Hash.new
	for i in 583...$pos_data.size
		covid_hash[$pos_data[i]["pos"]] = 0
	end
	covid_hash[:accumulated] = 0

	# make output_arr / push_back header(region name)
	output_arr = Array.new
	header_arr = Array.new
	header_arr << "date"
	covid_hash.each do |k,v|
		header_arr << k
	end
	header_arr << "accumulated"
	output_arr << header_arr

	# date | 강서구 .... | accumulated
	# as date increase, update covid_hash with region_accumulated, accumulated
	date = $covid_data[0]["date"].to_i
	for i in 0...$covid_data.size
		# End case
		if date == 20200601
			data_arr = Array.new
			data_arr << date
			covid_hash.each do |k,v|
				data_arr << v
			end
			#puts data_arr
			output_arr << data_arr

			# file write
			CSV.open("region_data.csv", "w+") do |csv|
				puts output_arr[3]
				for i in 0...output_arr.size
					csv << output_arr[i]
				end
			end
			break

		# when new date info --> covid_hash to data, push_back data, clear data, update date
		elsif date != $covid_data[i]["date"].to_i
			data_arr = Array.new
			data_arr << date
			covid_hash.each do |k,v|
				data_arr << v
			end
			output_arr << data_arr
			date = $covid_data[i]["date"].to_i
		end

		# update covid_hash
		covid_hash[$covid_data[i]["region"]] = $covid_data[i]["region_accumulated"]
		covid_hash[:accumulated] = $covid_data[i]["accumulated"]
	end
end

def line_file_gen_2(line, csv_file, ver)
	# load file
	csv_data = CSV.parse(File.read(csv_file))

	# get first row from column idx 1 (station list)
	station = Array.new
	for i in 1...csv_data[0].size
		station << csv_data[0][i]
	end

	if ver == 2019
		# find data
		output_arr = Array.new
		station.each do |v|
			row = Array.new
			puts v.to_s
			row << v
			for i in 0...$subway_data_2019.size
				if v == $subway_data_2019[i]["station"] and line == $subway_data_2019[i]["line"].to_i
					row << $subway_data_2019[i]["sum"]
				end
			end
			output_arr << row
		end
	elsif ver == 2020
		# find data
		output_arr = Array.new
		station.each do |v|
			row = Array.new
			puts v.to_s
			row << v
			for i in 0...$subway_data_2020.size
				if v == $subway_data_2020[i]["station"] and line == $subway_data_2020[i]["line"].to_i
					row << $subway_data_2020[i]["sum"]
				end
			end
			output_arr << row
		end
	end		

	# file write
	CSV.open(csv_file, "w+") do |csv|
		for i in 0...output_arr.size
			csv << output_arr[i]
		end
	end	
end


def line_file_gen(line, csv_file, ver)
	# load file
	csv_data = CSV.parse(File.read(csv_file))

	if ver == 2019
		# find data
		output_arr = Array.new
		for station in 0...csv_data.size
			row = Array.new
			puts csv_data[station][0].to_s
			row << csv_data[station][0]
			for i in 0...$subway_data_2019.size
				#puts csv_file[station] + " // " + $subway_data[i]["station"] .to_s
				if csv_data[station][0] == $subway_data_2019[i]["station"] and line == $subway_data_2019[i]["line"].to_i
					#date = $subway_data[i]["date"]
					row << $subway_data_2019[i]["sum"]
				end
			end
			output_arr << row
		end
	elsif ver == 2020
		# find data
		output_arr = Array.new
		for station in 0...csv_data.size
			row = Array.new
			puts csv_data[station][0].to_s
			row << csv_data[station][0]
			for i in 0...$subway_data_2020.size
				#puts csv_file[station] + " // " + $subway_data[i]["station"] .to_s
				if csv_data[station][0] == $subway_data_2020[i]["station"] and line == $subway_data_2020[i]["line"].to_i
					#date = $subway_data[i]["date"]
					row << $subway_data_2020[i]["sum"]
				end
			end
			output_arr << row
		end
	end

	# file write
	CSV.open(csv_file, "w+") do |csv|
		for i in 0...output_arr.size
			csv << output_arr[i]
		end
	end
end

line_file_gen(1,"line1_2(2019).csv",2019)
line_file_gen(3,"line3(2019).csv",2019)
line_file_gen(4,"line4(2019).csv",2019)