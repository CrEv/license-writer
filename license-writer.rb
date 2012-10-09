#!/usr/bin/ruby

# /!\ the program doesn't check if the license is yet added!
# Don't execute it 2 times.

licensefile = "license.txt"

license = IO.readlines(licensefile)

comments = Hash[
	"apps/**/*.rb" => Hash[
		"before" => "",
		"start" => "# ",
		"end" => "",
		"after" => "",
		"skip" => "oldlicense.txt"
	],
	"apps/**/*.sass" => Hash[
		"before" => "",
		"start" => "// ",
		"end" => "",
		"after" => "",
		"skip" => nil
	],
	"apps/**/*.js" => Hash[
		"before" => "/*",
		"start" => " * ",
		"end" => "",
		"after" => " */",
		"skip" => nil
		],
	"apps/**/*.haml" => Hash[
		"before" => "",
		"start" => "-# ",
		"end" => "",
		"after" => "",
		"skip" => nil
		],
	"apps/**/*.mustache" => Hash[
		"before" => "",
		"start" => "{{# ",
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
			print(".")

			skip = oldlicense.length > 0
			i = 0
			oldlicense.each do |line|
				if line != fileContent[i]
					skip = false
					i = 0
					break
				end
				i += 1
			end

			license.each do |line|
				f.write("#{comment['start']}#{line.chop}#{comment['end']}\n")
			end
			print(".")
			f.write("\n")
			f.write("\n")
			if skip
				print("X")
			else
				print(".")
			end
			until i > fileContent.length
				f.write(fileContent[i])
				i += 1
			end
			print(".")
		end
		File.delete(file)
		print(".")
		File.rename("#{file}_tmp", file)
		puts(".")
	end
end
