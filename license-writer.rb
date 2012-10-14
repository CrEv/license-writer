#!/usr/bin/ruby

# /!\ the program doesn't check if the license is yet added!
# Don't execute it 2 times.

licensefile = "license.txt"

license = IO.readlines(licensefile)

comments = Hash[
	"apps/**/*.rb" => Hash[
		"before" => "",
		"start" => "#",
		"end" => "",
		"after" => "",
		"skip" => "oldlicense.txt"
	],
	"apps/**/*.sass" => Hash[
		"before" => "",
		"start" => "//",
		"end" => "",
		"after" => "",
		"skip" => nil
	],
	"apps/**/*.js" => Hash[
		"before" => "/*",
		"start" => " *",
		"end" => "",
		"after" => " */",
		"skip" => nil
		],
	"apps/**/*.haml" => Hash[
		"before" => "",
		"start" => "-#",
		"end" => "",
		"after" => "",
		"skip" => nil
		],
	"apps/**/*.mustache" => Hash[
		"before" => "",
		"start" => "{{#",
		"end" => " }}",
		"after"=> "",
		"skip" => nil
	]
]

comments.each do |glob, comment|
	puts("")
	puts(" - check #{glob}")

	oldlicense = []
	oldlicense = IO.readlines(comment["skip"]) unless comment["skip"] == nil

	Dir.glob(glob) do |file|
		print(file.ljust(90))
		File.open("#{file}_tmp", "w") do |f|
			fileContent = IO.readlines(file)
			offset = 0
			print(".")

			if fileContent[offset][0, 3] == "#!/"
				f.write fileContent[offset]
				offset += 1
			end
			prefixidx = comment['start'].length + 4
			if fileContent[offset][0, prefixidx] == "#{comment['start']} -*-"
				f.write fileContent[offset]
				offset += 1
			end
			if fileContent[offset][0, prefixidx] == "#{comment['start']} vi:"
				f.write fileContent[offset]
				offset += 1
			end
			f.write "\n" if offset > 0

			skip = oldlicense.length > 0
			i = offset
			oldlicense.each do |line|
				if line != fileContent[i]
					skip = false
					i = offset
					break
				end
				i += 1
			end

			offset = i

			f.write("#{comment['before']}\n") if comment['before'] != ''
			license.each do |line|
				f.write("#{comment['start']} #{line.chop}#{comment['end']}\n")
			end
			f.write("#{comment['after']}\n") if comment['after'] != ''
			print(".")
			f.write("\n")
			f.write("\n")
			if skip
				print("X")
			else
				print(".")
			end
			until offset > fileContent.length
				f.write(fileContent[offset])
				offset += 1
			end
			print(".")
		end
		File.delete(file)
		print(".")
		File.rename("#{file}_tmp", file)
		puts(".")
	end
end
