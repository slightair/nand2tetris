chap = ARGV.first || "00"

directory = File.join(__dir__, chap)
problems = Dir.glob(File.join(directory, '**', '*.cmp')).sort

problems.each do |x|
    basename = x.sub(directory + File::SEPARATOR, "").chomp(".cmp")
    cmp = open(File.join(directory, "#{basename}.cmp")).read.gsub(/\r\n/, "\n") rescue next
    out = open(File.join(directory, "#{basename}.out")).read rescue nil
    result = cmp == out ? "✅" : "❌"

    puts "#{basename} - #{result}"
end
