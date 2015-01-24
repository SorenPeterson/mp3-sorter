require 'mp3info'

$accepted_filetypes = ["mp3"]
$filenames = [] # This array holds all of the filenames collected when add_files is called
$progress = 0
$counter = 0

START_TIME = Time.now.sec

### Mechanics:

# Directory Traversal

def to_human_byte_string(number)
  number = number / 8.0
  ['bytes', 'KB', 'MB', 'GB', 'TB'].each do |suffix|
    return ((number*100.0).floor/100.0).to_s + suffix unless (number / 1024).to_i > 0
    number = number / 1024
  end
  return "big"
end

def add_files(location)
  entries = Dir.entries(location.split('\\').join)
  unless IO.readlines("Results.txt")[-1] == "Finished"
    results = File.open("Results.txt", "w")
    entries.each_with_index do |entry, index|
      if entry != '.' and entry != '..'
        new_location = location+'/'+entry
        begin
          Dir.chdir(new_location)
          add_files(new_location)
          Dir.chdir('..')
        rescue
          if $accepted_filetypes.include?(new_location.split('.').last)
            $filenames << new_location
            results << new_location + "\n"
          end
        end
      end
    end
    results << "Finished"
  else
    puts "."
    File.open("Results.txt").each_line do |line|
      $filenames << line
    end
  end
end

PROGRAM_ROOT = Dir.getwd

puts "Where would you like to search? "

# If there is no input then the program runs with the directory saved in PreviousDirectory.txt
input = gets.chomp
open("PreviousDirectory.txt", "w").puts(input) unless input.empty?
input = input.empty? ? open("PreviousDirectory.txt", "r").gets.chomp : input.split("\\").join
add_files(input)
# puts $filenames.join("\n")

Dir.chdir(PROGRAM_ROOT)
open("Playlist.m3u", "w").puts($filenames.join("\n"))


