#!/usr/bin/ruby

# /!\ the program doesn't check if the license is yet added!
# Don't execute it 2 times.
#
# next: remove old licenses

licensefile = "license.txt"

license = IO.readlines(licensefile)

comments = Hash[
	"apps/**/*.rb" => ["# ", ""],
	"apps/**/*.coffee" => ["# ", ""],
	"apps/**/*.sass" => ["start" => "// ", "end" => ""],
	"apps/**/*.scss" => ["start" => "// ", "end" => ""],
	"apps/**/*.js" => ["// ", ""],
	"apps/**/*.haml" => ["-# ", ""],
	"apps/**/*.mustache" => ["{{# ", " }}"]
]

comments.each { |glob, comment|
	Dir.glob(glob) { |file|
		File.open("#{file}_tmp", "w") { |f|
			license.each {|line|
				f.write("#{comment[0]}#{line.chop}#{comment[1]}\n")
			}
			f.write("\n")
			f.write("\n")
			IO.readlines(file).each {|line|
				f.write(line)
			}
		}
		File.delete(file)
		File.rename("#{file}_tmp", file)
		puts("#{file} patched")
	}
}
